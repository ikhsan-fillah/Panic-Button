const pool = require('../config/db');

exports.show = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT rr.*, u.name AS changed_by_name
       FROM riwayat_respon rr
       JOIN users u ON rr.changed_by = u.id
       WHERE rr.laporan_id = ?
       ORDER BY rr.created_at ASC`,
      [req.params.laporan_id]
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};