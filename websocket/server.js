const WebSocket = require('ws');
const http = require('http');

const server = http.createServer();
const wss = new WebSocket.Server({ server });

// Store connected clients with their platform info
const clients = new Map();
let clientIdCounter = 0;

// Store canvas state (last 1000 drawing actions)
const canvasHistory = [];
const MAX_HISTORY = 1000;

console.log('WebSocket server starting...');

wss.on('connection', (ws) => {
    const clientId = ++clientIdCounter;
    console.log(`Client ${clientId} connected`);

    ws.on('message', (message) => {
        try {
            const data = JSON.parse(message);

            switch (data.type) {
                case 'join':
                    // Register client with platform info
                    clients.set(clientId, {
                        ws: ws,
                        platform: data.platform,
                        username: data.username || `User${clientId}`
                    });

                    // Send canvas history to new client
                    ws.send(JSON.stringify({
                        type: 'history',
                        history: canvasHistory
                    }));

                    // Broadcast updated user list
                    broadcastUserList();
                    console.log(`Client ${clientId} joined as ${data.platform}`);
                    break;

                case 'draw':
                    // Add to history
                    const drawData = {
                        type: 'draw',
                        x: data.x,
                        y: data.y,
                        color: data.color,
                        size: data.size,
                        platform: data.platform,
                        clientId: clientId
                    };

                    canvasHistory.push(drawData);
                    if (canvasHistory.length > MAX_HISTORY) {
                        canvasHistory.shift();
                    }

                    // Broadcast to all other clients
                    broadcast(drawData, clientId);
                    break;

                case 'clear':
                    // Clear canvas history
                    canvasHistory.length = 0;

                    // Broadcast clear command
                    broadcast({
                        type: 'clear',
                        platform: data.platform,
                        clientId: clientId
                    }, clientId);
                    console.log(`Canvas cleared by client ${clientId}`);
                    break;
            }
        } catch (error) {
            console.error('Error processing message:', error);
        }
    });

    ws.on('close', () => {
        console.log(`Client ${clientId} disconnected`);
        clients.delete(clientId);
        broadcastUserList();
    });

    ws.on('error', (error) => {
        console.error(`WebSocket error for client ${clientId}:`, error);
    });
});

function broadcast(data, excludeClientId = null) {
    const message = JSON.stringify(data);
    clients.forEach((client, id) => {
        if (id !== excludeClientId && client.ws.readyState === WebSocket.OPEN) {
            client.ws.send(message);
        }
    });
}

function broadcastUserList() {
    const users = Array.from(clients.entries()).map(([id, client]) => ({
        id: id,
        platform: client.platform,
        username: client.username
    }));

    const message = JSON.stringify({
        type: 'users',
        users: users,
        count: users.length
    });

    clients.forEach((client) => {
        if (client.ws.readyState === WebSocket.OPEN) {
            client.ws.send(message);
        }
    });
}

const PORT = 8081;
server.listen(PORT, () => {
    console.log(`WebSocket server is running on port ${PORT}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received, closing server...');
    wss.clients.forEach(client => client.close());
    server.close(() => {
        console.log('Server closed');
        process.exit(0);
    });
});
