const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  socketPath: process.env.INSTANCE_UNIX_SOCKET,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,

  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

module.exports = pool;