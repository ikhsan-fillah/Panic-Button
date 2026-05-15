const app = require('./src/app');
const pool = require('./src/config/db');
require('dotenv').config();

const PORT = process.env.PORT || 88080;

pool.getConnection()
  .then((connection) => {
    console.log('Database connected');
    connection.release();

    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error('DB ERROR:', err);
  });