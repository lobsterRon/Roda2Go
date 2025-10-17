// server.js
const express = require('express');
const WebSocket = require('ws');
const app = express();
const port = 3000;

// Serve a simple HTTP route (optional)
app.get('/', (req, res) => res.send('Roda2Go Server is Running'));

// Create HTTP + WebSocket server
const server = app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});

const wss = new WebSocket.Server({ server });

// When a client connects
wss.on('connection', ws => {
  console.log('Client connected');

  ws.on('message', message => {
    console.log('Received:', message);

    // Broadcast message to all clients
    wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(message);
      }
    });
  });

  ws.on('close', () => console.log('Client disconnected'));
});
