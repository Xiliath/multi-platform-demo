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
            .replace(/{{GO_ACTIVE}}/g, '')
            .replace(/{{RUST_ACTIVE}}/g, '');

        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(html);
    } else if (req.url === '/nodejs/canvas' || req.url === '/canvas') {
        const templatePath = path.join(__dirname, '../shared/templates/canvas.html');
        const template = fs.readFileSync(templatePath, 'utf8');

        const html = template.replace(/{{PLATFORM}}/g, 'Node.js');

        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(html);
    } else if (req.url === '/join' || req.url === '/nodejs/join') {
        const templatePath = path.join(__dirname, '../shared/templates/join.html');
        const html = fs.readFileSync(templatePath, 'utf8');

        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(html);
    } else if (req.url === '/registration' || req.url === '/nodejs/registration') {
        const templatePath = path.join(__dirname, '../shared/templates/registration.html');
        const template = fs.readFileSync(templatePath, 'utf8');

        const html = template.replace(/{{PLATFORM}}/g, 'Node.js');

        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(html);
    } else if (req.url === '/admin' || req.url === '/nodejs/admin') {
        const templatePath = path.join(__dirname, '../shared/templates/admin.html');
        const template = fs.readFileSync(templatePath, 'utf8');

        const html = template.replace(/{{PLATFORM}}/g, 'Node.js');

        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(html);
    } else if (req.url === '/blocked' || req.url === '/nodejs/blocked') {
        const templatePath = path.join(__dirname, '../shared/templates/blocked.html');
        const html = fs.readFileSync(templatePath, 'utf8');

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
