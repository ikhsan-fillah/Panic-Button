const crypto = require('crypto');
const pool = require('../config/db');
const { firestore, messaging, FieldValue } = require('../config/firebase');

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────

function tokenDocId(token) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

function parseCoordinate(value) {
  const number = Number(value);
  return Number.isFinite(number) ? number : null;
}

function isValidLatitude(value) {
  return value !== null && value >= -90 && value <= 90;
}

function isValidLongitude(value) {
  return value !== null && value >= -180 && value <= 180;
}

function normalizeFirestoreValue(value) {
  if (value && typeof value.toDate === 'function') {
    return value.toDate().toISOString();
  }
  return value;
}

function normalizeFirestoreDoc(doc) {
  const data = doc.data();
  const result = { id: doc.id };
  Object.entries(data).forEach(([key, value]) => {
    result[key] = normalizeFirestoreValue(value);
  });
  return result;
}

function chunkArray(items, size) {
  const chunks = [];
  for (let i = 0; i < items.length; i += size) {
    chunks.push(items.slice(i, i + size));
  }
  return chunks;
}

// ─────────────────────────────────────────────
// FCM HELPERS
// ─────────────────────────────────────────────

async function deactivateInvalidTokens(tokens, responses) {
  const invalidCodes = new Set([
    'messaging/invalid-registration-token',
    'messaging/registration-token-not-registered',
  ]);

  const batch = firestore.batch();
  let count = 0;

  responses.forEach((item, index) => {
    const code = item.error && item.error.code;
    if (!code || !invalidCodes.has(code)) return;

    const ref = firestore
      .collection('fcm_tokens')
      .doc(tokenDocId(tokens[index]));

    batch.set(
      ref,
      {
        active: false,
        disabled_reason: code,
        disabled_at: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
    count += 1;
  });

  if (count > 0) {
    await batch.commit();
  }
}

async function sendFcmToTokens(tokens, payload) {
  const chunks = chunkArray(tokens, 500);
  let successCount = 0;
  let failureCount = 0;

  for (const chunk of chunks) {
    const response = await messaging.sendEachForMulticast({
      tokens: chunk,
      notification: payload.notification,
      data: payload.data,
      android: {
        priority: 'high',
        notification: {
          channelId: 'emergency',
          priority: 'max',
          sound: 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            contentAvailable: true,
          },
        },
      },
    });

    successCount += response.successCount;
    failureCount += response.failureCount;
    await deactivateInvalidTokens(chunk, response.responses);
  }

  return { successCount, failureCount };
}

// ─────────────────────────────────────────────
// CONTROLLERS
// ─────────────────────────────────────────────

/**
 * POST /fcm-token
 * Simpan atau perbarui FCM token milik user yang sedang login.
 *
 * FIX:
 * - created_at hanya ditulis saat dokumen belum ada (pakai transaction
 *   agar read → write bersifat atomic, mencegah race condition).
 */
exports.saveFcmToken = async (req, res) => {
  try {
    const { token, fcm_token, platform, device_id, device_name } = req.body;

    // Terima field `fcm_token` (mobile) maupun `token` (kompatibilitas internal)
    const finalToken = fcm_token || token;

    if (!finalToken || typeof finalToken !== 'string') {
      return res.status(400).json({ message: 'FCM token wajib dikirim' });
    }

    const ref = firestore.collection('fcm_tokens').doc(tokenDocId(finalToken));

    // Gunakan Firestore transaction agar created_at tidak tertimpa saat update
    await firestore.runTransaction(async (tx) => {
      const snapshot = await tx.get(ref);
      const isNew = !snapshot.exists;

      const payload = {
        token: finalToken,
        user_id: req.user.id,
        user_name: req.user.name,
        role: req.user.role,
        platform: platform || null,
        device_id: device_id || null,
        device_name: device_name || null,
        active: true,
        updated_at: FieldValue.serverTimestamp(),
      };

      // created_at hanya diisi saat dokumen baru pertama kali dibuat
      if (isNew) {
        payload.created_at = FieldValue.serverTimestamp();
      }

      tx.set(ref, payload, { merge: true });
    });

    return res.status(201).json({ message: 'FCM token berhasil disimpan' });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

/**
 * POST /location
 * Simpan koordinat terbaru user ke MySQL (historis) dan Firestore (realtime).
 *
 * FIX:
 * - MySQL insert duluan; Firestore hanya diperbarui setelah MySQL sukses.
 *   Kalau Firestore gagal, koordinat tetap tersimpan di MySQL dan error
 *   dikembalikan ke client tanpa data ganda.
 */
exports.updateLocation = async (req, res) => {
  try {
    const latitude = parseCoordinate(req.body.latitude);
    const longitude = parseCoordinate(req.body.longitude);
    const accuracy =
      req.body.accuracy === undefined
        ? null
        : parseCoordinate(req.body.accuracy);

    if (!isValidLatitude(latitude) || !isValidLongitude(longitude)) {
      return res
        .status(400)
        .json({ message: 'Latitude atau longitude tidak valid' });
    }

    // 1. MySQL dulu (data historis)
    await pool.query(
      'INSERT INTO lokasi (user_id, latitude, longitude) VALUES (?, ?, ?)',
      [req.user.id, latitude, longitude]
    );

    // 2. Firestore setelah MySQL sukses (data realtime)
    await firestore
      .collection('active_locations')
      .doc(String(req.user.id))
      .set(
        {
          user_id: req.user.id,
          user_name: req.user.name,
          role: req.user.role,
          latitude,
          longitude,
          accuracy,
          is_active: true,
          last_seen: FieldValue.serverTimestamp(),
          updated_at: FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

    return res.json({
      message: 'Lokasi aktif berhasil diperbarui',
      data: { user_id: req.user.id, latitude, longitude, accuracy },
    });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

/**
 * GET /active-locations
 * Ambil lokasi aktif dari Firestore.
 *
 * FIX:
 * - Filter `is_active` dan `role` dikerjakan di sisi Firestore (bukan
 *   load semua dokumen ke memori) untuk mengurangi pembacaan & alokasi RAM.
 * - Filter waktu tetap di memori karena Firestore tidak mendukung
 *   perbandingan timestamp + field lain sekaligus tanpa composite index.
 */
exports.activeLocations = async (req, res) => {
  try {
    const minutes = Number.isFinite(Number(req.query.minutes))
      ? Number(req.query.minutes)
      : 10;
    const includeAll = req.query.all === 'true';
    const role = req.query.role;
    const cutoffMs = Date.now() - minutes * 60 * 1000;

    // Buat query dasar dengan filter is_active langsung di Firestore
    let query = firestore
      .collection('active_locations')
      .where('is_active', '==', true);

    // Filter role juga di Firestore kalau ada, agar dokumen yang dibaca lebih sedikit
    if (role) {
      query = query.where('role', '==', role);
    }

    const snapshot = await query.get();

    const locations = snapshot.docs
      .map(normalizeFirestoreDoc)
      .filter((item) => {
        if (includeAll) return true;
        if (!item.last_seen) return false;
        return new Date(item.last_seen).getTime() >= cutoffMs;
      })
      .sort(
        (a, b) =>
          new Date(b.last_seen || 0) - new Date(a.last_seen || 0)
      );

    return res.json(locations);
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

/**
 * POST /broadcast
 * Kirim broadcast darurat ke semua warga.
 *
 * FIX (urutan eksekusi):
 *   1. Ambil data warga dari MySQL
 *   2. Bulk-insert notifikasi ke MySQL dalam satu transaction
 *   3. Baru buat dokumen Firestore (status: 'processing')
 *   4. Kirim FCM
 *   5. Update Firestore ke status 'sent' / 'failed'
 *
 * Dengan urutan ini:
 * - Kalau MySQL gagal → Firestore belum tersentuh, tidak ada data
 *   setengah jalan.
 * - Kalau Firestore / FCM gagal → notifikasi DB sudah tersimpan dan
 *   status di Firestore diupdate ke 'failed' agar bisa di-retry.
 * - Loop INSERT diganti bulk INSERT satu query (jauh lebih cepat).
 */
exports.sendBroadcast = async (req, res) => {
  try {
    const { title, message, priority } = req.body;

    if (!title || !message) {
      return res
        .status(400)
        .json({ message: 'Title dan message wajib dikirim' });
    }

    // ── 1. Ambil semua user warga ────────────────────────────────────
    const [wargaRows] = await pool.query(
      `SELECT id FROM users WHERE role = 'warga'`
    );

    // ── 2. Bulk-insert notifikasi dalam satu MySQL transaction ────────
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      if (wargaRows.length > 0) {
        // Satu query INSERT … VALUES (…),(…),(…) jauh lebih efisien
        // daripada N query di dalam loop
        const values = wargaRows.map((w) => [
          w.id,
          null,   // laporan_id
          title,
          message,
          false,  // is_read
        ]);

        await conn.query(
          `INSERT INTO notifikasi
             (user_id, laporan_id, title, message, is_read)
           VALUES ?`,
          [values]
        );
      }

      await conn.commit();
    } catch (dbError) {
      await conn.rollback();
      throw dbError; // lempar ke catch luar
    } finally {
      conn.release();
    }

    // ── 3. Buat dokumen Firestore setelah MySQL sukses ────────────────
    const broadcastRef = await firestore
      .collection('emergency_broadcast')
      .add({
        title,
        message,
        priority: priority || 'tinggi',
        sender_id: req.user.id,
        sender_name: req.user.name,
        status: 'processing',
        sent_count: 0,
        failure_count: 0,
        created_at: FieldValue.serverTimestamp(),
        updated_at: FieldValue.serverTimestamp(),
      });

    // ── 4. Ambil token aktif & kirim FCM ─────────────────────────────
    const tokenSnapshot = await firestore
      .collection('fcm_tokens')
      .where('active', '==', true)
      .where('role', '==', 'warga')
      .get();

    const tokens = tokenSnapshot.docs
      .map((doc) => doc.data().token)
      .filter(Boolean);

    let result = { successCount: 0, failureCount: 0 };

    try {
      if (tokens.length > 0) {
        result = await sendFcmToTokens(tokens, {
          notification: { title, body: message },
          data: {
            type: 'emergency_broadcast',
            broadcast_id: broadcastRef.id,
            priority: priority || 'tinggi',
          },
        });
      }

      // ── 5a. Update Firestore → sent ───────────────────────────────
      await broadcastRef.update({
        status: 'sent',
        total_token: tokens.length,
        sent_count: result.successCount,
        failure_count: result.failureCount,
        updated_at: FieldValue.serverTimestamp(),
      });
    } catch (fcmError) {
      // ── 5b. FCM gagal → tandai di Firestore, tetap kembalikan error
      await broadcastRef.update({
        status: 'failed',
        error_message: fcmError.message,
        updated_at: FieldValue.serverTimestamp(),
      });
      throw fcmError;
    }

    return res.status(201).json({
      message: 'Broadcast darurat berhasil diproses',
      broadcast_id: broadcastRef.id,
      total_token: tokens.length,
      sent_count: result.successCount,
      failure_count: result.failureCount,
    });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

/**
 * GET /broadcast-history
 * Riwayat broadcast dari Firestore.
 */
exports.broadcastHistory = async (req, res) => {
  try {
    const rawLimit = Number(req.query.limit || 50);
    const limit = Number.isFinite(rawLimit)
      ? Math.min(rawLimit, 100)
      : 50;

    const snapshot = await firestore
      .collection('emergency_broadcast')
      .orderBy('created_at', 'desc')
      .limit(limit)
      .get();

    return res.json(snapshot.docs.map(normalizeFirestoreDoc));
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

/**
 * GET /latest-alarm
 * Notifikasi SOS terbaru dari Firestore.
 */
exports.latestAlarm = async (req, res) => {
  try {
    const snapshot = await firestore
      .collection('sos_notifications')
      .orderBy('created_at', 'desc')
      .limit(1)
      .get();

    if (snapshot.empty) {
      return res.json(null);
    }

    return res.json(normalizeFirestoreDoc(snapshot.docs[0]));
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};