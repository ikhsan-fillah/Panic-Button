const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const path = require('path');
const apiRoutes = require('./routes/api');

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

app.use('/api', apiRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'Panic Button API running' });
});

module.exports = app;