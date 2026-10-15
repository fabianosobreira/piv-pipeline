const express = require('express');
const auth = require('./middleware/auth');

const app = express();
app.use(express.json());
app.use(auth);

app.get('/v1/items', (req, res) => res.json([]));

module.exports = app;
