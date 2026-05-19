import { useEffect, useState } from 'react';
import api from '../api/axios';
import { toast } from 'react-toastify';
import { Radio } from 'lucide-react';

export default function Broadcast() {
  const [title, setTitle] = useState('');
  const [pesan,   setPesan]   = useState('');
  const [riwayat, setRiwayat] = useState([]);
  const [loading,  setLoading]  = useState(false);
  const [fetching, setFetching] = useState(true); 
  const loadBroadcast = async () => {
    try {
      setFetching(true);
      const r = await api.get('/broadcast');
      setRiwayat(r.data.data || r.data || []);
    } catch (err) {
      console.log(err);
    } finally {
      setFetching(false);
    }
  };

  useEffect(() => {
    const init = async () => {
      await loadBroadcast();
    };
    init();
  }, []);

  const handleSend = async () => {
    if (!pesan.trim()) return;
    setLoading(true);
    try {
      await api.post('/broadcast', {title, message: pesan});
      toast.success('Broadcast berhasil dikirim ke semua warga!');
      setTitle('');
      setPesan('');
      loadBroadcast();
    } catch {
      toast.error('Gagal mengirim broadcast.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ padding: '32px 36px' }}>
      <h2 style={{ fontSize: 22, fontWeight: 700, marginBottom: 6, marginTop: 0 }}>
        Broadcast Darurat
      </h2>
      <p style={{ color: '#64748b', fontSize: 14, marginBottom: 28, marginTop: 0 }}>
        Kirim pesan darurat ke seluruh warga secara realtime.
      </p>

      <div style={{
        background: '#fff',
        borderRadius: 12,
        padding: '24px 28px',
        boxShadow: '0 1px 3px rgba(0,0,0,0.08)',
        marginBottom: 24,
      }}>
        <h3 style={{ marginTop: 0, marginBottom: 18, fontSize: 15, fontWeight: 700 }}>
          📢 Kirim Pesan Broadcast
        </h3>

        <label style={{ display: 'block', fontSize: 13, fontWeight: 600, color: '#475569', marginBottom: 6 }}>
          Judul
        </label>
        <input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Judul broadcast..."
          style={{
            width: '100%',
            padding: '10px 14px',
            border: '1.5px solid #e2e8f0',
            borderRadius: 8,
            fontSize: 14,
            marginBottom: 16,
            boxSizing: 'border-box',
          }}
        />

        <label style={{ display: 'block', fontSize: 13, fontWeight: 600, color: '#475569', marginBottom: 6 }}>
          Pesan
        </label>
        <textarea
          value={pesan}
          onChange={e => setPesan(e.target.value)}
          placeholder="Tulis pesan darurat untuk seluruh warga..."
          style={{
            width: '100%',
            height: 100,
            padding: '10px 14px',
            border: '1.5px solid #e2e8f0',
            borderRadius: 8,
            fontSize: 14,
            resize: 'vertical',
            boxSizing: 'border-box',
            marginBottom: 20,
          }}
        />
        <button
          onClick={handleSend}
          disabled={loading}
          style={{
            padding: '10px 24px',
            background: '#262692',
            color: '#fff',
            border: 'none',
            borderRadius: 8,
            cursor: loading ? 'not-allowed' : 'pointer',
            fontWeight: 700,
            fontSize: 14,
            display: 'flex',
            alignItems: 'center',
            gap: 8,
            opacity: loading ? 0.7 : 1,
          }}
        >
          <Radio size={16} /> {loading ? 'Mengirim...' : 'Kirim Broadcast'}
        </button>
      </div>
      
      <div style={{ background: '#fff', borderRadius: 12, padding: 24, boxShadow: '0 1px 3px rgba(0,0,0,0.08)' }}>
        <h3 style={{ marginTop: 0, fontSize: 16 }}>Riwayat Broadcast</h3>
        {fetching ? (
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '20px 0', color: '#94a3b8' }}>
            <div style={{
              width: 18, height: 18, border: '2px solid #e2e8f0',
              borderTopColor: '#ef4444', borderRadius: '50%',
              animation: 'spin 0.7s linear infinite',
            }} />
            <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
            Memuat riwayat...
          </div>
        ) : riwayat.length === 0 ? (
          <p style={{ color: '#94a3b8', margin: 0 }}>Belum ada broadcast yang dikirim.</p>
        ) : (
          riwayat.map(b => (
            <div key={b.id} style={{ padding: '12px 0', borderBottom: '1px solid #f1f5f9' }}>
              <p style={{ margin: 0, fontWeight: 500 }}>{b.pesan || b.message}</p>
              <p style={{ margin: '4px 0 0', fontSize: 12, color: '#94a3b8' }}>
                {new Date(b.created_at).toLocaleString('id-ID')}
              </p>
            </div>
          ))
        )}
      </div>
    </div>
  );
}