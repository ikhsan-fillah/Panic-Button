const pool = require('../config/db');

exports.index = async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM kategori ORDER BY id DESC');
  res.json(rows);
};

exports.store = async (req, res) => {
  const { nama } = req.body;
  const [result] = await pool.query('INSERT INTO kategori (nama) VALUES (?)', [nama]);
  res.status(201).json({ message: 'Kategori berhasil ditambahkan', id: result.insertId });
};

exports.update = async (req, res) => {
  const { nama } = req.body;
  await pool.query('UPDATE kategori SET nama = ? WHERE id = ?', [nama, req.params.id]);
  res.json({ message: 'Kategori berhasil diupdate' });
};

exports.destroy = async (req, res) => {
  await pool.query('DELETE FROM kategori WHERE id = ?', [req.params.id]);
  res.json({ message: 'Kategori berhasil dihapus' });
};