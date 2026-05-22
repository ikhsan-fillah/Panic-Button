const pool = require("../config/db");
const {
  createSosRealtime,
  syncLaporanRealtime,
} = require("../services/realtimeService");

exports.store = async (req, res) => {
  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const {
      kategori_id,
      judul,
      deskripsi,
      latitude,
      longitude,
      alamat,
      priority,
    } = req.body;

    const [kategoriRows] = await connection.query(
      "SELECT nama FROM kategori WHERE id = ?",
      [kategori_id],
    );

    if (kategoriRows.length === 0) {
      return res.status(404).json({ message: "Kategori tidak ditemukan" });
    }

    const kategoriNama = kategoriRows[0].nama;
    const finalJudul = judul && judul.trim() ? judul.trim() : kategoriNama;

    const [result] = await connection.query(
      `INSERT INTO laporan (user_id, kategori_id, judul, deskripsi, latitude, longitude, alamat, priority, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'pending')`,
      [
        req.user.id,
        kategori_id,
        finalJudul,
        deskripsi,
        latitude,
        longitude,
        alamat,
        priority || "sedang",
      ],
    );

    await connection.query(
      `INSERT INTO riwayat_respon (laporan_id, changed_by, status, catatan)
       VALUES (?, ?, ?, ?)`,
      [result.insertId, req.user.id, "pending", "Laporan dibuat"],
    );

    const [satpamRows] = await connection.query(
      `SELECT id FROM users WHERE role = 'satpam'`,
    );

    if (satpamRows.length > 0) {
      const notifValues = satpamRows.map((satpam) => [
        satpam.id,
        result.insertId,
        `SOS: ${finalJudul}`,
        deskripsi || "Ada laporan baru",
        false,
      ]);

      await connection.query(
        `INSERT INTO notifikasi (user_id, laporan_id, title, message, is_read)
         VALUES ?`,
        [notifValues],
      );
    }

    await connection.commit();

    await createSosRealtime(result.insertId).catch((firebaseError) => {
      console.error("Firebase SOS sync gagal:", firebaseError.message);
    });

    res.status(201).json({
      message: "Laporan berhasil dibuat",
      laporan_id: result.insertId,
      total_satpam_notified: satpamRows.length,
    });
  } catch (error) {
    try {
      await connection.rollback();
    } catch (rollbackError) {
      console.error("Rollback gagal:", rollbackError.message);
    }

    res.status(500).json({ message: error.message });
  } finally {
    connection.release();
  }
};

exports.index = async (req, res) => {
  try {
    const { status } = req.query;
    let sql = `SELECT l.*, u.name AS user_name, k.nama AS kategori_nama
               FROM laporan l
               JOIN users u ON l.user_id = u.id
               JOIN kategori k ON l.kategori_id = k.id`;
    const params = [];
    if (status) {
      sql += " WHERE l.status = ?";
      params.push(status);
    }
    sql += " ORDER BY l.created_at DESC";
    const [rows] = await pool.query(sql, params);
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.show = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT l.*, u.name AS user_name, k.nama AS kategori_nama
       FROM laporan l
       JOIN users u ON l.user_id = u.id
       JOIN kategori k ON l.kategori_id = k.id
       WHERE l.id = ?`,
      [req.params.id],
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: "Laporan tidak ditemukan" });
    }

    res.json(rows[0]);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.userLaporan = async (req, res) => {
  try {
    const [rows] = await pool.query(
      "SELECT * FROM laporan WHERE user_id = ? ORDER BY created_at DESC",
      [req.user.id],
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.update = async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT * FROM laporan WHERE id = ?", [
      req.params.id,
    ]);

    if (rows.length === 0) {
      return res.status(404).json({ message: "Laporan tidak ditemukan" });
    }

    const laporan = rows[0];
    const judul = req.body.judul || laporan.judul;
    const deskripsi = req.body.deskripsi || laporan.deskripsi;
    const priority = req.body.priority || laporan.priority;
    const status = req.body.status || laporan.status;

    await pool.query(
      `UPDATE laporan
       SET judul = ?, deskripsi = ?, priority = ?, status = ?
       WHERE id = ?`,
      [judul, deskripsi, priority, status, req.params.id],
    );

    await pool.query(
      `INSERT INTO riwayat_respon (laporan_id, changed_by, status, catatan)
       VALUES (?, ?, ?, ?)`,
      [
        req.params.id,
        req.user.id,
        status,
        `Status laporan diubah menjadi ${status}`,
      ],
    );

    await syncLaporanRealtime(
      req.params.id,
      `Status laporan diubah menjadi ${status}`,
    ).catch((firebaseError) => {
      console.error("Firebase status sync gagal:", firebaseError.message);
    });

    res.json({ message: "Laporan berhasil diupdate" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.cancel = async (req, res) => {
  try {
    await pool.query("UPDATE laporan SET status = ? WHERE id = ?", [
      "cancel",
      req.params.id,
    ]);

    await pool.query(
      `INSERT INTO riwayat_respon (laporan_id, changed_by, status, catatan)
       VALUES (?, ?, ?, ?)`,
      [req.params.id, req.user.id, "cancel", "Laporan dibatalkan oleh warga"],
    );

    await syncLaporanRealtime(
      req.params.id,
      "Laporan dibatalkan oleh warga",
    ).catch((firebaseError) => {
      console.error("Firebase cancel sync gagal:", firebaseError.message);
    });

    res.json({ message: "Laporan dibatalkan" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.uploadFoto = async (req, res) => {
  try {
    if (!req.file || !req.file.gcsUrl) {
      return res.status(400).json({ message: "File foto wajib diupload" });
    }

    const fotoUrl = req.file.gcsUrl;

    await pool.query("UPDATE laporan SET foto = ? WHERE id = ?", [
      fotoUrl,
      req.params.id,
    ]);

    await syncLaporanRealtime(req.params.id, "Foto kejadian diperbarui").catch(
      (firebaseError) => {
        console.error("Firebase foto sync gagal:", firebaseError.message);
      },
    );

    res.json({ message: "Foto berhasil diupload", foto: fotoUrl });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
