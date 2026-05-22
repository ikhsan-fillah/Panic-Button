const crypto = require('crypto');
const pool = require('../config/db');
const { firestore, messaging, FieldValue } = require('../config/firebase');

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

    const ref = firestore.collection('fcm_tokens').doc(tokenDocId(tokens[index]));
    batch.set(ref, {
      active: false,
      disabled_reason: code,
      disabled_at: FieldValue.serverTimestamp(),
    }, { merge: true });
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

exports.saveFcmToken = async (req, res) => {
  try {
    // Mobile Person 1 mengirim field `fcm_token`.
    // Backend juga tetap menerima `token` agar kompatibel dengan dokumentasi internal Person 4.
    const { token, fcm_token, platform, device_id, device_name } = req.body;
    const finalToken = token || fcm_token;

    if (!finalToken || typeof finalToken !== 'string') {
      return res.status(400).json({ message: 'FCM token wajib dikirim' });
    }

    const ref = firestore.collection('fcm_tokens').doc(tokenDocId(finalToken));
    const snapshot = await ref.get();

    await ref.set({
      token: finalToken,
      user_id: req.user.id,
      user_name: req.user.name,
      role: req.user.role,
      platform: platform || null,
      device_id: device_id || null,
      device_name: device_name || null,
      active: true,
      created_at: snapshot.exists ? snapshot.data().created_at : FieldValue.serverTimestamp(),
      updated_at: FieldValue.serverTimestamp(),
    }, { merge: true });

    return res.status(201).json({ message: 'FCM token berhasil disimpan' });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

exports.updateLocation = async (req, res) => {
  try {
    const latitude = parseCoordinate(req.body.latitude);
    const longitude = parseCoordinate(req.body.longitude);
    const accuracy = req.body.accuracy === undefined ? null : parseCoordinate(req.body.accuracy);

    if (!isValidLatitude(latitude) || !isValidLongitude(longitude)) {
      return res.status(400).json({ message: 'Latitude atau longitude tidak valid' });
    }

    await pool.query(
      'INSERT INTO lokasi (user_id, latitude, longitude) VALUES (?, ?, ?)',
      [req.user.id, latitude, longitude]
    );

    await firestore.collection('active_locations').doc(String(req.user.id)).set({
      user_id: req.user.id,
      user_name: req.user.name,
      role: req.user.role,
      latitude,
      longitude,
      accuracy,
      is_active: true,
      last_seen: FieldValue.serverTimestamp(),
      updated_at: FieldValue.serverTimestamp(),
    }, { merge: true });

    return res.json({
      message: 'Lokasi aktif berhasil diperbarui',
      data: {
        user_id: req.user.id,
        latitude,
        longitude,
        accuracy,
      },
    });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

exports.activeLocations = async (req, res) => {
  try {
    const minutes = Number(req.query.minutes || 10);
    const includeAll = req.query.all === 'true';
    const role = req.query.role;
    const cutoffMs = Date.now() - (Number.isFinite(minutes) ? minutes : 10) * 60 * 1000;

    const snapshot = await firestore.collection('active_locations').get();
    const locations = snapshot.docs
      .map(normalizeFirestoreDoc)
      .filter((item) => item.is_active !== false)
      .filter((item) => !role || item.role === role)
      .filter((item) => {
        if (includeAll) return true;
        if (!item.last_seen) return false;
        return new Date(item.last_seen).getTime() >= cutoffMs;
      })
      .sort((a, b) => new Date(b.last_seen || 0) - new Date(a.last_seen || 0));

    return res.json(locations);
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

exports.sendBroadcast = async (req, res) => {
  try {
    const { title, message, priority } = req.body;

    if (!title || !message) {
      return res.status(400).json({ message: 'Title dan message wajib dikirim' });
    }

    const broadcastRef = await firestore.collection('emergency_broadcast').add({
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

    const tokenSnapshot = await firestore
      .collection('fcm_tokens')
      .where('active', '==', true)
      .where('role', '==', 'warga')
      .get();

    const tokens = tokenSnapshot.docs
      .map((doc) => doc.data().token)
      .filter(Boolean);
      
    // ambil semua user warga
    const [wargaRows] = await pool.query(
      `SELECT id FROM users WHERE role = 'warga'`
    );

    // simpan ke tabel notifikasi
    if (wargaRows.length > 0) {
      const notifValues = wargaRows.map((warga) => [
        warga.id,
        null,
        title,
        message,
        false,
      ]);

      await pool.query(
        `INSERT INTO notifikasi
        (user_id, laporan_id, title, message, is_read)
        VALUES ?`,
        [notifValues]
      );
    }

    let result = { successCount: 0, failureCount: 0 };

    if (tokens.length > 0) {
      result = await sendFcmToTokens(tokens, {
        notification: {
          title,
          body: message,
        },
        data: {
          type: 'emergency_broadcast',
          broadcast_id: broadcastRef.id,
          priority: priority || 'tinggi',
        },
      });
    }

    await broadcastRef.update({
      status: 'sent',
      total_token: tokens.length,
      sent_count: result.successCount,
      failure_count: result.failureCount,
      updated_at: FieldValue.serverTimestamp(),
    });

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

exports.broadcastHistory = async (req, res) => {
  try {
    const limit = Math.min(Number(req.query.limit || 50), 100);
    const snapshot = await firestore
      .collection('emergency_broadcast')
      .orderBy('created_at', 'desc')
      .limit(Number.isFinite(limit) ? limit : 50)
      .get();

    return res.json(snapshot.docs.map(normalizeFirestoreDoc));
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

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
