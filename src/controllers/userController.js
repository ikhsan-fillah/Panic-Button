const pool = require('../config/db');
const bcrypt = require('bcryptjs');

exports.index = async (req, res) => {
  const [rows] = await pool.query('SELECT id, name, email, phone, role, created_at FROM users ORDER BY id DESC');
  res.json(rows);
};

exports.show = async (req, res) => {
  const [rows] = await pool.query('SELECT id, name, email, phone, role, created_at FROM users WHERE id = ?', [req.params.id]);
  if (rows.length === 0) return res.status(404).json({ message: 'User tidak ditemukan' });
  res.json(rows[0]);
};

exports.update = async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT * FROM users WHERE id = ?',
      [req.params.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        message: 'User tidak ditemukan',
      });
    }

    const user = rows[0];

    const name = req.body.name || user.name;
    const email = req.body.email || user.email;
    const phone = req.body.phone || user.phone;
    const role = req.body.role || user.role;

    const [existingEmail] = await pool.query(
      'SELECT id FROM users WHERE email = ? AND id != ?',
      [email, req.params.id]
    );

    if (existingEmail.length > 0) {
      return res.status(400).json({
        message: 'Email sudah digunakan',
      });
    }

    if (req.body.password) {
      const hashedPassword = await bcrypt.hash(
        req.body.password,
        10
      );

      await pool.query(
        `UPDATE users
         SET name = ?, email = ?, phone = ?, role = ?, password = ?
         WHERE id = ?`,
        [
          name,
          email,
          phone,
          role,
          hashedPassword,
          req.params.id,
        ]
      );
    } else {
      await pool.query(
        `UPDATE users
         SET name = ?, email = ?, phone = ?, role = ?
         WHERE id = ?`,
        [
          name,
          email,
          phone,
          role,
          req.params.id,
        ]
      );
    }

    res.json({
      message: 'User berhasil diupdate',
    });
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};

exports.destroy = async (req, res) => {
  await pool.query('DELETE FROM users WHERE id = ?', [req.params.id]);
  res.json({ message: 'User berhasil dihapus' });
};