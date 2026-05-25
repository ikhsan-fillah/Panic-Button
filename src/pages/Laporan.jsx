import { useEffect, useState } from 'react';
import api from '../api/axios';
import StatusBadge from '../components/StatusBadge';
import { toast } from 'react-toastify';
import { useLocation, useNavigate } from 'react-router-dom';

const STATUS_OPTIONS = ['pending','menuju_lokasi','diproses','selesai','cancel'];
export default function Laporan() {
  const [laporan, setLaporan] = useState([]);
  const [filter, setFilter]   = useState('');
  const [selected, setSelected] = useState(null);
  const [catatan, setCatatan]   = useState('');
  const [newStatus, setNewStatus] = useState('');
  const [loading, setLoading] = useState(true);
  const location = useLocation();
  const navigate = useNavigate();

  const fetchLaporan = async (status = '') => {
    try {
      setLoading(true);
      const url = status
        ? `/laporan?status=${status}`
        : '/laporan';
      const res = await api.get(url);
      setLaporan(
        res.data.data || res.data || []
      );
    } catch (err) {
      console.log(err);
      toast.error('Gagal mengambil laporan.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    const loadData = async () => {
      await fetchLaporan(filter);
    };
    loadData();
  }, [filter]);

  useEffect(() => {
    if (
      location.state?.selectedId &&
      laporan.length > 0 &&
      !selected
    ) {
      const found = laporan.find(
        (l) => l.id === location.state.selectedId
      );
      if (found) {
        // eslint-disable-next-line react-hooks/set-state-in-effect
        setSelected(found);
        setNewStatus(found.status);
        setCatatan('');
        navigate('/laporan', {
          replace: true,
        });
      }
    }
  }, [location.state, laporan, selected, navigate]);

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
    } catch {
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
                  <td style={{ padding: '12px 16px' }}>{l.user_name || l.user_id}</td>
                  <td style={{ padding: '12px 16px', fontWeight: 500 }}>{l.judul}</td>
                  <td style={{ padding: '12px 16px' }}>{l.kategori_nama || '-'}</td>
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

            {/* ── Modal Header ── */}
            <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginBottom: 20 }}>
              <div>
                <p style={{ margin: 0, fontSize: 11, fontWeight: 700, color: '#94a3b8', letterSpacing: '0.07em', textTransform: 'uppercase' }}>
                  Detail Laporan
                </p>
                <h3 style={{ margin: '4px 0 0', fontSize: 18, fontWeight: 700, color: '#0f172a' }}>
                  #{selected.id} — {selected.judul}
                </h3>
              </div>
              <button
                onClick={() => setSelected(null)}
                style={{ flexShrink: 0, width: 30, height: 30, borderRadius: 8, border: 'none', background: '#f1f5f9', color: '#64748b', cursor: 'pointer', fontSize: 14, lineHeight: 1 }}
              >
                ✕
              </button>
            </div>

            {/* ── Info Grid ── */}
            <div style={{ background: '#f8fafc', borderRadius: 10, padding: '14px 16px', marginBottom: 16, display: 'grid', gap: 10 }}>
              {[
                { label: 'Deskripsi',  value: selected.deskripsi || '—' },
                { label: 'Alamat',     value: selected.alamat },
                { label: 'Koordinat', value: `${selected.latitude}, ${selected.longitude}` },
                { label: 'Prioritas', value: selected.priority, capitalize: true },
              ].map(({ label, value, capitalize }) => (
                <div key={label} style={{ display: 'flex', gap: 8, alignItems: 'baseline' }}>
                  <span style={{ flexShrink: 0, fontSize: 11, fontWeight: 700, color: '#94a3b8', textTransform: 'uppercase', letterSpacing: '0.05em', width: 72 }}>
                    {label}
                  </span>
                  <span style={{ fontSize: 13, color: '#334155', textTransform: capitalize ? 'capitalize' : 'none', lineHeight: 1.5 }}>
                    {value}
                  </span>
                </div>
              ))}
            </div>

            {/* ── Rute Button ── */}
            <a
              href={`https://www.google.com/maps/dir/?api=1&destination=${selected.latitude},${selected.longitude}`}
              target="_blank"
              rel="noreferrer"
              style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: 6,
                padding: '8px 16px',
                background: '#2563eb',
                color: '#fff',
                borderRadius: 8,
                textDecoration: 'none',
                fontWeight: 600,
                fontSize: 13,
                marginBottom: 16,
              }}
            >
              <svg width="13" height="13" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5S10.62 6.5 12 6.5s2.5 1.12 2.5 2.5S13.38 11.5 12 11.5z"/>
              </svg>
              Rute ke Lokasi
            </a>

            {/* ── Foto ── */}
            {selected.foto && (
              <img
                src={
                  selected.foto.startsWith('http')
                    ? selected.foto
                    : `https://panic-button-api-311142907128.us-central1.run.app/storage/${selected.foto}`
                }
                alt="Foto kejadian"
                style={{ width: '100%', borderRadius: 10, marginBottom: 16, objectFit: 'cover', maxHeight: 220, display: 'block' }}
                onError={(e) => { e.target.style.display = 'none'; }}
              />
            )}

            <hr style={{ border: 'none', borderTop: '1px solid #f1f5f9', margin: '4px 0 16px' }} />

            {/* ── Update Status ── */}
            <p style={{ margin: '0 0 10px', fontSize: 12, fontWeight: 700, color: '#94a3b8', textTransform: 'uppercase', letterSpacing: '0.06em' }}>
              Update Status
            </p>
            <select value={newStatus} onChange={e => setNewStatus(e.target.value)} style={modal.input}>
              {STATUS_OPTIONS.map(s => <option key={s} value={s}>{s}</option>)}
            </select>
            <textarea
              placeholder="Catatan penanganan (opsional)"
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
  overlay: {
    position: 'fixed', inset: 0,
    background: 'rgba(15,23,42,0.6)',
    backdropFilter: 'blur(4px)',
    display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 999,
  },
  box: {
    background: '#fff', borderRadius: 16, padding: 24,
    width: '100%', maxWidth: 520, maxHeight: '88vh', overflowY: 'auto',
    boxShadow: '0 20px 60px rgba(0,0,0,0.2)',
  },
  input: {
    width: '100%', padding: '9px 12px',
    border: '1.5px solid #e2e8f0', borderRadius: 8, fontSize: 13,
    marginBottom: 10, boxSizing: 'border-box', display: 'block',
    background: '#fafbfc', color: '#334155',
  },
  btnPrimary: {
    padding: '8px 22px', background: '#ef4444', color: '#fff',
    border: 'none', borderRadius: 8, cursor: 'pointer', fontWeight: 600, fontSize: 13,
  },
  btnSecondary: {
    padding: '8px 18px', background: '#f1f5f9', color: '#374151',
    border: 'none', borderRadius: 8, cursor: 'pointer', fontWeight: 600, fontSize: 13,
  },
};