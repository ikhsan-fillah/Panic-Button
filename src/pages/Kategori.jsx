import { useEffect, useState } from 'react';
import api from '../api/axios';
import { toast } from 'react-toastify';
import { Plus, Trash2, Pencil } from 'lucide-react';

export default function Kategori() {
  const [list, setList] = useState([]);
  const [nama, setNama] = useState('');
  const [editing, setEditing] = useState(null);

  const fetchKategori = async () => {
    try {
      const r = await api.get('/kategori');
      setList(r.data.data || r.data || []);
    } catch (err) {
      console.log(err);
    }
  };

  useEffect(() => {
    const loadData = async () => {
      try {
        const r = await api.get('/kategori');
        setList(r.data.data || r.data || []);
      } catch (err) {
        console.log(err);
      }
    };
    loadData();
  }, []);

  const handleSave = async () => {
    if (!nama.trim()) return;
    try {
      if (editing) {
        await api.put(`/kategori/${editing.id}`, {
          nama
        });
        toast.success('Kategori diupdate!');
      } else {
        await api.post('/kategori', {
          nama
        });
        toast.success('Kategori ditambahkan!');
      }
      setNama('');
      setEditing(null);
      fetchKategori();
    } catch {
      toast.error('Gagal menyimpan.');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Hapus kategori ini?')) return;
    try {
      await api.delete(`/kategori/${id}`);
      toast.success('Kategori dihapus.');
      fetchKategori();
    } catch {
      toast.error('Gagal menghapus.');
    }
  };

  return (
    <div style={{ padding: 32 }}>
      <h2 style={{ fontSize: 22, fontWeight: 700, marginBottom: 20 }}>Manajemen Kategori Kejadian</h2>
      <div style={{ display: 'flex', gap: 10, marginBottom: 24 }}>
        <input
          value={nama} onChange={e => setNama(e.target.value)}
          placeholder="Nama kategori baru..."
          style={{ flex: 1, padding: '9px 14px', border: '1.5px solid #e2e8f0', borderRadius: 8, fontSize: 14 }}
        />
        <button onClick={handleSave}
          style={{ padding: '9px 20px', background: '#0f172a', color: '#fff', border: 'none', borderRadius: 8, cursor: 'pointer', fontWeight: 600, display: 'flex', alignItems: 'center', gap: 6 }}>
          <Plus size={16} /> {editing ? 'Update' : 'Tambah'}
        </button>
        {editing && (
          <button onClick={() => { setEditing(null); setNama(''); }}
            style={{ padding: '9px 14px', background: '#f1f5f9', border: 'none', borderRadius: 8, cursor: 'pointer' }}>
            Batal
          </button>
        )}
      </div>
      <div style={{ background: '#fff', borderRadius: 12, boxShadow: '0 1px 3px rgba(0,0,0,0.08)', overflow: 'hidden' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
          <thead style={{ background: '#f8fafc' }}>
            <tr>
              <th style={th}>ID</th><th style={th}>Nama Kategori</th><th style={th}>Dibuat</th><th style={th}>Aksi</th>
            </tr>
          </thead>
          <tbody>
            {list.map(k => (
              <tr key={k.id} style={{ borderBottom: '1px solid #f1f5f9' }}>
                <td style={td}>#{k.id}</td>
                <td style={{ ...td, fontWeight: 500 }}>{k.nama}</td>
                <td style={td}>{new Date(k.created_at).toLocaleDateString('id-ID')}</td>
                <td style={td}>
                  <button onClick={() => { setEditing(k); setNama(k.nama); }} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#3b82f6', marginRight: 8 }}>
                    <Pencil size={15} />
                  </button>
                  <button onClick={() => handleDelete(k.id)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#ef4444' }}>
                    <Trash2 size={15} />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
const th = { padding: '12px 16px', textAlign: 'left', color: '#64748b', fontWeight: 600 };
const td = { padding: '12px 16px' };