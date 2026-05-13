const pool = require('../config/db');

exports.index = async (req, res) => {
  const [rows] = await pool.query(
    'SELECT * FROM notifikasi WHERE user_id = ? ORDER BY created_at DESC',
    [req.user.id]
  );
  res.json(rows);
};

exports.markRead = async (req, res) => {
  await pool.query('UPDATE notifikasi SET is_read = TRUE WHERE id = ?', [req.params.id]);
  res.json({ message: 'Notifikasi ditandai dibaca' });
};