const pool = require('../config/db');
const { firestore, FieldValue } = require('../config/firebase');

const laporanDetailSql = `
  SELECT
    l.*,
    u.name AS user_name,
    u.phone AS user_phone,
    k.nama AS kategori_nama
  FROM laporan l
  JOIN users u ON l.user_id = u.id
  JOIN kategori k ON l.kategori_id = k.id
  WHERE l.id = ?
`;

function toNumber(value) {
  if (value === null || value === undefined || value === '') return null;
  const number = Number(value);
  return Number.isFinite(number) ? number : null;
}

function isActiveStatus(status) {
  return !['selesai', 'cancel'].includes(status);
}

function buildLaporanPayload(laporan) {
  return {
    laporan_id: laporan.id,
    user_id: laporan.user_id,
    user_name: laporan.user_name,
    user_phone: laporan.user_phone || null,
    kategori_id: laporan.kategori_id,
    kategori_nama: laporan.kategori_nama,
    judul: laporan.judul,
    deskripsi: laporan.deskripsi,
    latitude: toNumber(laporan.latitude),
    longitude: toNumber(laporan.longitude),
    alamat: laporan.alamat || null,
    priority: laporan.priority,
    status: laporan.status,
    foto: laporan.foto || null,
    mysql_created_at: laporan.created_at,
    mysql_updated_at: laporan.updated_at,
  };
}

async function getLaporanDetail(laporanId) {
  const [rows] = await pool.query(laporanDetailSql, [laporanId]);
  return rows[0] || null;
}

async function createSosRealtime(laporanId) {
  const laporan = await getLaporanDetail(laporanId);
  if (!laporan) return null;

  const payload = buildLaporanPayload(laporan);
  const now = FieldValue.serverTimestamp();

  await Promise.all([
    firestore.collection('sos_notifications').add({
      ...payload,
      type: 'SOS',
      title: `SOS: ${laporan.judul}`,
      message: laporan.deskripsi,
      is_read: false,
      created_at: now,
    }),

    firestore.collection('active_reports').doc(String(laporanId)).set({
      ...payload,
      is_active: true,
      created_at: now,
      updated_at: now,
    }, { merge: true }),

    firestore.collection('realtime_status').doc(String(laporanId)).set({
      laporan_id: laporan.id,
      user_id: laporan.user_id,
      status: laporan.status,
      message: 'Laporan SOS baru diterima',
      updated_at: now,
    }, { merge: true }),
  ]);

  return payload;
}

async function syncLaporanRealtime(laporanId, message = 'Status laporan diperbarui') {
  const laporan = await getLaporanDetail(laporanId);
  if (!laporan) return null;

  const payload = buildLaporanPayload(laporan);
  const active = isActiveStatus(laporan.status);
  const now = FieldValue.serverTimestamp();

  await Promise.all([
    firestore.collection('realtime_status').doc(String(laporanId)).set({
      laporan_id: laporan.id,
      user_id: laporan.user_id,
      status: laporan.status,
      message,
      updated_at: now,
    }, { merge: true }),

    firestore.collection('active_reports').doc(String(laporanId)).set({
      ...payload,
      is_active: active,
      closed_at: active ? null : now,
      updated_at: now,
    }, { merge: true }),
  ]);

  return payload;
}

module.exports = {
  createSosRealtime,
  syncLaporanRealtime,
};
