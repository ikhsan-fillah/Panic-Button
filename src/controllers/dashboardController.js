const pool = require('../config/db');

exports.statistik = async (req, res) => {
  const [total] = await pool.query('SELECT COUNT(*) AS total FROM laporan');
  const [pending] = await pool.query("SELECT COUNT(*) AS total FROM laporan WHERE status = 'pending'");
  const [diproses] = await pool.query("SELECT COUNT(*) AS total FROM laporan WHERE status = 'diproses'");
  const [selesai] = await pool.query("SELECT COUNT(*) AS total FROM laporan WHERE status = 'selesai'");
  const [cancel] = await pool.query("SELECT COUNT(*) AS total FROM laporan WHERE status = 'cancel'");

  res.json({
    total: total[0].total,
    pending: pending[0].total,
    diproses: diproses[0].total,
    selesai: selesai[0].total,
    cancel: cancel[0].total,
  });
};

exports.hariIni = async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM laporan WHERE DATE(created_at) = CURDATE() ORDER BY created_at DESC');
  res.json(rows);
};

exports.prioritasTinggi = async (req, res) => {
  const [rows] = await pool.query("SELECT * FROM laporan WHERE priority = 'tinggi' AND status NOT IN ('selesai', 'cancel') ORDER BY created_at DESC");
  res.json(rows);
};

exports.areaRawan = async (req, res) => {
  const [rows] = await pool.query(
    `SELECT alamat, COUNT(*) AS jumlah_laporan
     FROM laporan
     GROUP BY alamat
     ORDER BY jumlah_laporan DESC
     LIMIT 10`
  );
  res.json(rows);
};

exports.laporanMasuk = async (req, res) => {
  const [rows] = await pool.query(
    `SELECT * FROM laporan
     WHERE status IN ('pending', 'menuju_lokasi', 'diproses')
     ORDER BY created_at DESC`
  );
  res.json(rows);
};