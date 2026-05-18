const pool = require('../config/db');
const { syncLaporanRealtime } = require('../services/realtimeService');

exports.store = async (req, res) => {
  try {
    const { laporan_id, status, catatan } = req.body;

    const [existing] = await pool.query(
      'SELECT id FROM penanganan WHERE laporan_id = ?',
      [laporan_id]
    );

    if (existing.length > 0) {
      await pool.query(
        `UPDATE penanganan 
         SET satpam_id = ?, status = ?, catatan = ?
         WHERE laporan_id = ?`,
        [req.user.id, status, catatan, laporan_id]
      );
    } else {
      await pool.query(
        `INSERT INTO penanganan 
         (laporan_id, satpam_id, status, catatan)
         VALUES (?, ?, ?, ?)`,
        [laporan_id, req.user.id, status, catatan]
      );
    }

    await pool.query(
      'UPDATE laporan SET status = ? WHERE id = ?',
      [status, laporan_id]
    );

    await pool.query(
      `INSERT INTO riwayat_respon
       (laporan_id, changed_by, status, catatan)
       VALUES (?, ?, ?, ?)`,
      [
        laporan_id,
        req.user.id,
        status,
        catatan || 'Update penanganan',
      ]
    );

    await syncLaporanRealtime(laporan_id, catatan || `Status laporan diubah menjadi ${status}`).catch((firebaseError) => {
      console.error('Firebase penanganan sync gagal:', firebaseError.message);
    });

    res.status(201).json({
      message: 'Penanganan berhasil disimpan',
    });
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};

exports.show = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT 
          p.*,
          u.name AS satpam_name,
          l.judul,
          l.deskripsi,
          l.status AS laporan_status
       FROM penanganan p
       JOIN users u ON p.satpam_id = u.id
       JOIN laporan l ON p.laporan_id = l.id
       WHERE p.laporan_id = ?`,
      [req.params.laporan_id]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        message: 'Penanganan tidak ditemukan',
      });
    }

    res.json(rows[0]);
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};

exports.updateByLaporan = async (req, res) => {
  try {
    const { status, catatan } = req.body;

    const [rows] = await pool.query(
      'SELECT * FROM penanganan WHERE laporan_id = ?',
      [req.params.laporan_id]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        message: 'Penanganan tidak ditemukan',
      });
    }

    const penanganan = rows[0];

    const updatedStatus = status || penanganan.status;
    const updatedCatatan = catatan || penanganan.catatan;

    await pool.query(
      `UPDATE penanganan
       SET status = ?, catatan = ?
       WHERE laporan_id = ?`,
      [
        updatedStatus,
        updatedCatatan,
        req.params.laporan_id,
      ]
    );

    await pool.query(
      `UPDATE laporan
       SET status = ?
       WHERE id = ?`,
      [
        updatedStatus,
        req.params.laporan_id,
      ]
    );

    await pool.query(
      `INSERT INTO riwayat_respon
       (laporan_id, changed_by, status, catatan)
       VALUES (?, ?, ?, ?)`,
      [
        req.params.laporan_id,
        req.user.id,
        updatedStatus,
        updatedCatatan || 'Update penanganan',
      ]
    );

    await syncLaporanRealtime(req.params.laporan_id, updatedCatatan || `Status laporan diubah menjadi ${updatedStatus}`).catch((firebaseError) => {
      console.error('Firebase update penanganan sync gagal:', firebaseError.message);
    });

    res.json({
      message: 'Penanganan berhasil diupdate',
    });
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};