const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 5001;

const server = http.createServer((req, res) => {
    if (req.url === '/nodejs' || req.url === '/') {
        const templatePath = path.join(__dirname, '../shared/templates/index.html');
        const template = fs.readFileSync(templatePath, 'utf8');

        const html = template
            .replace(/{{PLATFORM}}/g, 'Node.js')
            .replace(/{{VERSION}}/g, process.version)
            .replace(/{{TIMESTAMP}}/g, new Date().toISOString().replace('T', ' ').substring(0, 19) + ' UTC')
            .replace(/{{CANVAS_LINK}}/g, '/nodejs/canvas')
            .replace(/{{DOTNET_ACTIVE}}/g, '')
            .replace(/{{NODEJS_ACTIVE}}/g, 'active')
            .replace(/{{PYTHON_ACTIVE}}/g, '')
            .replace(/{{JAVA_ACTIVE}}/g, '')
            .replace(/{{GO_ACTIVE}}/g, '');

        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(html);
    } else if (req.url === '/nodejs/canvas' || req.url === '/canvas') {
        const templatePath = path.join(__dirname, '../shared/templates/canvas.html');
        const template = fs.readFileSync(templatePath, 'utf8');

        const html = template.replace(/{{PLATFORM}}/g, 'Node.js');

        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(html);
    } else {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('Not Found');
    }
});

server.listen(PORT, () => {
    console.log(`Node.js server running on port ${PORT}`);
});
