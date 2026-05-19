const pool = require('../config/db');

exports.index = async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT * FROM notifikasi WHERE user_id = ? ORDER BY created_at DESC',
      [req.user.id]
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.markRead = async (req, res) => {
  try {
    const [result] = await pool.query(
      'UPDATE notifikasi SET is_read = TRUE WHERE id = ? AND user_id = ?',
      [req.params.id, req.user.id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Notifikasi tidak ditemukan' });
    }

    res.json({ message: 'Notifikasi ditandai dibaca' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};