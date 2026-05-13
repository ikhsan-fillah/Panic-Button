const pool = require('../config/db');

exports.activeReports = async (req, res) => {
  const [rows] = await pool.query(
    `SELECT id, judul, latitude, longitude, alamat, status, priority
     FROM laporan
     WHERE status NOT IN ('selesai', 'cancel')`
  );
  res.json(rows);
};

exports.heatmap = async (req, res) => {
  const [rows] = await pool.query(
    `SELECT latitude, longitude, COUNT(*) AS bobot
     FROM laporan
     GROUP BY latitude, longitude`
  );
  res.json(rows);
};