import { useEffect, useState } from 'react';
import api from '../api/axios';
import { toast } from 'react-toastify';
import { Trash2, Pencil } from 'lucide-react';

export default function Users() {
  const [users, setUsers] = useState([]);
  const [roleFilter, setRoleFilter] = useState('');

  const fetch = () => {
    api.get('/users').then(res => setUsers(res.data.data || res.data || []));
  };
  useEffect(fetch, []);

  const handleDelete = async (id) => {
    if (!window.confirm('Hapus user ini?')) return;
    await api.delete(`/users/${id}`);
    toast.success('User dihapus.');
    fetch();
  };

  const filtered = roleFilter ? users.filter(u => u.role === roleFilter) : users;

  return (
    <div style={{ padding: 32 }}>
      <h2 style={{ fontSize: 22, fontWeight: 700, marginBottom: 20 }}>Manajemen User</h2>
      <div style={{ display: 'flex', gap: 8, marginBottom: 16 }}>
        {['', 'warga', 'satpam'].map(r => (
          <button key={r} onClick={() => setRoleFilter(r)}
            style={{
              padding: '6px 16px', borderRadius: 999, border: '1.5px solid',
              cursor: 'pointer', fontSize: 12, fontWeight: 600,
              borderColor: roleFilter === r ? '#0f172a' : '#e2e8f0',
              background: roleFilter === r ? '#0f172a' : '#fff',
              color: roleFilter === r ? '#fff' : '#64748b',
            }}>
            {r || 'Semua'}
          </button>
        ))}
      </div>
      <div style={{ background: '#fff', borderRadius: 12, boxShadow: '0 1px 3px rgba(0,0,0,0.08)', overflow: 'hidden' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
          <thead style={{ background: '#f8fafc' }}>
            <tr>
              {['ID','Nama','Email','No. HP','Role','Dibuat'].map(h => (
                <th key={h} style={{ padding: '12px 16px', textAlign: 'left', color: '#64748b', fontWeight: 600 }}>{h}</th>
              ))}
              <th style={{ padding: '12px 16px' }}>Aksi</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map(u => (
              <tr key={u.id} style={{ borderBottom: '1px solid #f1f5f9' }}>
                <td style={{ padding: '12px 16px' }}>#{u.id}</td>
                <td style={{ padding: '12px 16px', fontWeight: 500 }}>{u.name}</td>
                <td style={{ padding: '12px 16px' }}>{u.email}</td>
                <td style={{ padding: '12px 16px' }}>{u.phone || '-'}</td>
                <td style={{ padding: '12px 16px' }}>
                  <span style={{
                    padding: '3px 10px', borderRadius: 999, fontSize: 11, fontWeight: 700,
                    background: u.role === 'satpam' ? '#dbeafe' : '#fef3c7',
                    color: u.role === 'satpam' ? '#1d4ed8' : '#92400e',
                  }}>{u.role}</span>
                </td>
                <td style={{ padding: '12px 16px' }}>{new Date(u.created_at).toLocaleDateString('id-ID')}</td>
                <td style={{ padding: '12px 16px' }}>
                  <button onClick={() => handleDelete(u.id)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#ef4444' }}>
                    <Trash2 size={16} />
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