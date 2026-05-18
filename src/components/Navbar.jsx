import { useAuth } from '../context/AuthContext';
import { Bell, Shield, CheckCheck } from 'lucide-react';
import { useState, useEffect, useRef } from 'react';
import { collection, onSnapshot, query, orderBy, limit } from 'firebase/firestore';
import { db } from '../firebase/firebaseConfig';

export default function Navbar({ title }) {
  const { user } = useAuth();
  const [notifs, setNotifs]           = useState([]);
  const [showDropdown, setShowDropdown] = useState(false);
  const [readIds, setReadIds]          = useState(new Set());
  const dropdownRef                    = useRef(null);

  useEffect(() => {
    const q = query(
      collection(db, 'sos_notifications'),
      orderBy('created_at', 'desc'),
      limit(20)
    );

    const unsub = onSnapshot(q, (snap) => {
      const data = snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setNotifs(data);
    }, (err) => {
      console.error('Navbar notif listener error:', err);
    });

    return () => unsub();
  }, []);

  useEffect(() => {
    const handler = (e) => {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target)) {
        setShowDropdown(false);
      }
    };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, []);

  const unreadCount = notifs.filter(n => !readIds.has(n.id)).length;

  const markAsRead = (id) => {
    setReadIds(prev => new Set([...prev, id]));
  };

  const markAllRead = () => {
    setReadIds(new Set(notifs.map(n => n.id)));
  };

  const formatTime = (val) => {
    if (!val) return '';
    const date = val?.toDate ? val.toDate() : new Date(val);
    const now   = new Date();
    const diff  = Math.floor((now - date) / 1000);
    if (diff < 60)   return `${diff}d lalu`;
    if (diff < 3600) return `${Math.floor(diff/60)}m lalu`;
    if (diff < 86400) return `${Math.floor(diff/3600)}j lalu`;
    return date.toLocaleDateString('id-ID');
  };

  return (
    <header style={styles.navbar}>
      <h1 style={styles.title}>{title}</h1>

      <div style={styles.right}>
        <div style={{ position: 'relative' }} ref={dropdownRef}>
          <button
            onClick={() => setShowDropdown(s => !s)}
            style={styles.bellBtn}
            title="Notifikasi SOS"
          >
            <Bell size={20} color={unreadCount > 0 ? '#ef4444' : '#64748b'} />
            {unreadCount > 0 && (
              <span style={styles.badge}>{unreadCount > 9 ? '9+' : unreadCount}</span>
            )}
          </button>

          {showDropdown && (
            <div style={styles.dropdown}>
              <div style={styles.dropdownHeader}>
                <span style={styles.dropdownTitle}>Notifikasi SOS</span>
                {unreadCount > 0 && (
                  <button onClick={markAllRead} style={styles.markAllBtn}>
                    <CheckCheck size={12} /> Tandai semua
                  </button>
                )}
              </div>

              <div style={{ maxHeight: 340, overflowY: 'auto' }}>
                {notifs.length === 0 ? (
                  <p style={styles.empty}>Tidak ada notifikasi</p>
                ) : (
                  notifs.slice(0, 10).map(n => {
                    const isRead = readIds.has(n.id);
                    const nama   = n.nama_warga || n.nama || n.user_name || 'Warga';
                    const judul  = n.judul || n.title || 'Laporan Darurat';
                    const alamat = n.alamat || n.lokasi || '';
                    return (
                      <div
                        key={n.id}
                        onClick={() => markAsRead(n.id)}
                        style={{
                          ...styles.notifItem,
                          background: isRead ? '#fff' : '#fef2f2',
                          borderLeft: isRead ? '3px solid transparent' : '3px solid #ef4444',
                        }}
                      >
                        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 3 }}>
                          <span style={{ fontSize: 14 }}>🚨</span>
                          <p style={styles.notifTitle}>{nama}</p>
                          {!isRead && (
                            <span style={styles.dotUnread} />
                          )}
                        </div>
                        <p style={styles.notifMsg}>{judul}</p>
                        {alamat && <p style={{ ...styles.notifMsg, fontSize: 11 }}>📍 {alamat}</p>}
                        <p style={styles.notifTime}>
                          {formatTime(n.created_at)}
                        </p>
                      </div>
                    );
                  })
                )}
              </div>
            </div>
          )}
        </div>

        <div style={styles.userInfo}>
          <div style={styles.avatar}>
            <Shield size={16} color="#fff" />
          </div>
          <div>
            <p style={styles.userName}>{user?.name || 'Satpam'}</p>
            <p style={styles.userRole}>Petugas Keamanan</p>
          </div>
        </div>
      </div>
    </header>
  );
}

const styles = {
  navbar: {
    height: 64, background: '#fff', borderBottom: '1px solid #e2e8f0',
    display: 'flex', alignItems: 'center', justifyContent: 'space-between',
    padding: '0 32px', position: 'sticky', top: 0, zIndex: 50,
  },
  title: { fontSize: 18, fontWeight: 700, color: '#0f172a', margin: 0 },
  right: { display: 'flex', alignItems: 'center', gap: 16 },
  bellBtn: {
    position: 'relative', background: 'none', border: 'none',
    cursor: 'pointer', padding: 8, borderRadius: 8,
    display: 'flex', alignItems: 'center',
  },
  badge: {
    position: 'absolute', top: 2, right: 2,
    background: '#ef4444', color: '#fff',
    fontSize: 9, fontWeight: 700, borderRadius: 999,
    minWidth: 16, height: 16, display: 'flex',
    alignItems: 'center', justifyContent: 'center',
    padding: '0 3px',
  },
  dropdown: {
    position: 'absolute', top: 48, right: 0, width: 320,
    background: '#fff', borderRadius: 12,
    boxShadow: '0 8px 32px rgba(0,0,0,0.15)',
    border: '1px solid #e2e8f0', zIndex: 999, overflow: 'hidden',
  },
  dropdownHeader: {
    padding: '12px 16px',
    borderBottom: '1px solid #f1f5f9',
    display: 'flex', alignItems: 'center', justifyContent: 'space-between',
  },
  dropdownTitle: { fontWeight: 700, fontSize: 13, color: '#0f172a' },
  markAllBtn: {
    display: 'flex', alignItems: 'center', gap: 4,
    fontSize: 11, color: '#64748b', background: 'none',
    border: 'none', cursor: 'pointer', padding: '2px 6px',
    borderRadius: 4,
  },
  empty: { padding: '20px 16px', color: '#94a3b8', fontSize: 13, textAlign: 'center', margin: 0 },
  notifItem: {
    padding: '10px 14px', borderBottom: '1px solid #f8fafc',
    cursor: 'pointer', transition: 'background 0.15s',
  },
  notifTitle: { margin: 0, fontWeight: 600, fontSize: 13, color: '#0f172a' },
  notifMsg: { margin: '2px 0 0', fontSize: 12, color: '#64748b' },
  notifTime: { margin: '4px 0 0', fontSize: 11, color: '#94a3b8' },
  dotUnread: {
    width: 7, height: 7, borderRadius: '50%',
    background: '#ef4444', flexShrink: 0,
  },
  userInfo: { display: 'flex', alignItems: 'center', gap: 10 },
  avatar: {
    width: 36, height: 36, borderRadius: 999,
    background: '#0f172a', display: 'flex',
    alignItems: 'center', justifyContent: 'center',
  },
  userName: { margin: 0, fontSize: 13, fontWeight: 600, color: '#0f172a' },
  userRole: { margin: 0, fontSize: 11, color: '#94a3b8' },
};
