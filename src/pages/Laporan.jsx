import { useEffect, useState } from 'react';
import api from '../api/axios';
import StatusBadge from '../components/StatusBadge';
import { toast } from 'react-toastify';

const STATUS_OPTIONS = ['pending','menuju_lokasi','diproses','selesai','cancel'];
export default function Laporan() {
  const [laporan, setLaporan] = useState([]);
  const [filter, setFilter]   = useState('');
  const [selected, setSelected] = useState(null);
  const [catatan, setCatatan]   = useState('');
  const [newStatus, setNewStatus] = useState('');
  const [loading, setLoading] = useState(true);

  const fetchLaporan = (status = '') => {
    setLoading(true);
    const url = status ? `/laporan?status=${status}` : '/laporan';
    api.get(url).then(res => setLaporan(res.data.data || res.data || []))
      .finally(() => setLoading(false));
  };

  useEffect(() => { fetchLaporan(filter); }, [filter]);

  const handleUpdate = async () => {
    if (!newStatus) return;
    try {
      await api.post('/penanganan', {
        laporan_id: selected.id,
        status: newStatus,
        catatan,
      });
      toast.success('Status berhasil diupdate!');
      setSelected(null);
      fetchLaporan(filter);
    } catch (e) {
      toast.error('Gagal update status.');
    }
  };

  return (
    <div style={{ padding: 32 }}>
      <h2 style={{ fontSize: 22, fontWeight: 700, marginBottom: 20 }}>Laporan Masuk</h2>

      <div style={{ marginBottom: 16, display: 'flex', gap: 8 }}>
        {['', ...STATUS_OPTIONS].map(s => (
          <button key={s} onClick={() => setFilter(s)}
            style={{
              padding: '6px 14px', borderRadius: 999, border: '1.5px solid',
              cursor: 'pointer', fontSize: 12, fontWeight: 600,
              borderColor: filter === s ? '#ef4444' : '#e2e8f0',
              background: filter === s ? '#ef4444' : '#fff',
              color: filter === s ? '#fff' : '#64748b',
            }}>
            {s || 'Semua'}
          </button>
        ))}
      </div>

      {loading ? <p>Memuat...</p> : (
        <div style={{ background: '#fff', borderRadius: 12, boxShadow: '0 1px 3px rgba(0,0,0,0.08)', overflow: 'hidden' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
            <thead>
              <tr style={{ background: '#f8fafc' }}>
                {['ID','Warga','Judul','Kategori','Prioritas','Status','Waktu','Aksi'].map(h => (
                  <th key={h} style={{ padding: '12px 16px', textAlign: 'left', color: '#64748b', fontWeight: 600 }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {laporan.map(l => (
                <tr key={l.id} style={{ borderBottom: '1px solid #f1f5f9' }}>
                  <td style={{ padding: '12px 16px' }}>#{l.id}</td>
                  <td style={{ padding: '12px 16px' }}>{l.user?.name || l.user_id}</td>
                  <td style={{ padding: '12px 16px', fontWeight: 500 }}>{l.judul}</td>
                  <td style={{ padding: '12px 16px' }}>{l.kategori?.nama || '-'}</td>
                  <td style={{ padding: '12px 16px' }}>
                    <span style={{
                      color: l.priority === 'tinggi' ? '#ef4444' : l.priority === 'sedang' ? '#f59e0b' : '#64748b',
                      fontWeight: 600, textTransform: 'capitalize',
                    }}>{l.priority}</span>
                  </td>
                  <td style={{ padding: '12px 16px' }}><StatusBadge status={l.status} /></td>
                  <td style={{ padding: '12px 16px' }}>{new Date(l.created_at).toLocaleString('id-ID')}</td>
                  <td style={{ padding: '12px 16px' }}>
                    <button onClick={() => { setSelected(l); setNewStatus(l.status); setCatatan(''); }}
                      style={{ padding: '5px 12px', background: '#0f172a', color: '#fff', border: 'none', borderRadius: 6, cursor: 'pointer', fontSize: 12 }}>
                      Detail
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {selected && (
        <div style={modal.overlay} onClick={() => setSelected(null)}>
          <div style={modal.box} onClick={e => e.stopPropagation()}>
            <h3 style={{ marginTop: 0 }}>Detail Laporan #{selected.id}</h3>
            <p><b>Judul:</b> {selected.judul}</p>
            <p><b>Deskripsi:</b> {selected.deskripsi}</p>
            <p><b>Alamat:</b> {selected.alamat}</p>
            <p><b>Koordinat:</b> {selected.latitude}, {selected.longitude}</p>
            <p><b>Priority:</b> {selected.priority}</p>
            {selected.foto && (
            <img
              src={
                selected.foto.startsWith('http')
                  ? selected.foto
                  : `https://panic-button-api-311142907128.us-central1.run.app/storage/${selected.foto}`
              }
              alt="Foto kejadian"
              style={{ width: '100%', borderRadius: 8, marginBottom: 12, objectFit: 'cover', maxHeight: 220 }}
              onError={(e) => {
                e.target.style.display = 'none'; 
              }}
            />
          )}
            <hr style={{ margin: '16px 0' }} />
            <h4>Update Status</h4>
            <select value={newStatus} onChange={e => setNewStatus(e.target.value)} style={modal.input}>
              {STATUS_OPTIONS.map(s => <option key={s} value={s}>{s}</option>)}
            </select>
            <textarea
              placeholder="Catatan penanganan"
              value={catatan} onChange={e => setCatatan(e.target.value)}
              style={{ ...modal.input, height: 80, resize: 'vertical' }}
            />
            <div style={{ display: 'flex', gap: 8, justifyContent: 'flex-end' }}>
              <button onClick={() => setSelected(null)} style={modal.btnSecondary}>Tutup</button>
              <button onClick={handleUpdate} style={modal.btnPrimary}>Simpan</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

const modal = {
  overlay: { position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 999 },
  box: { background: '#fff', borderRadius: 16, padding: 28, width: '100%', maxWidth: 520, maxHeight: '85vh', overflowY: 'auto' },
  input: { width: '100%', padding: '8px 12px', border: '1.5px solid #e2e8f0', borderRadius: 8, fontSize: 13, marginBottom: 10, boxSizing: 'border-box', display: 'block' },
  btnPrimary: { padding: '8px 20px', background: '#ef4444', color: '#fff', border: 'none', borderRadius: 8, cursor: 'pointer', fontWeight: 600 },
  btnSecondary: { padding: '8px 20px', background: '#f1f5f9', color: '#374151', border: 'none', borderRadius: 8, cursor: 'pointer', fontWeight: 600 },
};