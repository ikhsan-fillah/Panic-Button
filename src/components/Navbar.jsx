import { useAuth } from '../context/AuthContext';
import { Bell, Shield, CheckCheck } from 'lucide-react';
import { useState, useEffect, useMemo, useRef, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../api/axios';
import { db } from '../firebase/firebaseConfig';
import {
  collection,
  onSnapshot,
  orderBy,
  query,
  limit,
} from 'firebase/firestore';

export default function Navbar({ title }) {
  const { user } = useAuth();
  const navigate = useNavigate();
  const dropdownRef = useRef(null);

  const [showDropdown, setShowDropdown] = useState(false);
  const [backendNotifs, setBackendNotifs] = useState([]);
  const [realtimeNotifs, setRealtimeNotifs] = useState([]);

  const fetchBackendNotifikasi = useCallback(async () => {
    try {
      const res = await api.get('/notifikasi');
      setBackendNotifs(Array.isArray(res.data) ? res.data : []);
    } catch (err) {
      console.error('Gagal ambil notifikasi backend:', err);
    }
  }, []);

  useEffect(() => {
    const init = async () => {
      try {
        const res = await api.get('/notifikasi');
        setBackendNotifs(
          Array.isArray(res.data)
            ? res.data
            : []
        );
      } catch (err) {
        console.error('Gagal ambil notifikasi backend:', err);
      }
    };
    init();
  }, []);

  useEffect(() => {
    const q = query(
      collection(db, 'sos_notifications'),
      orderBy('created_at', 'desc'),
      limit(20)
    );
    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        const items = snapshot.docs.map((doc) => ({
          realtime_id: doc.id,
          ...doc.data(),
        }));
        setRealtimeNotifs(items);
      },
      (error) => {
        console.error('Gagal listen realtime notif:', error);
      }
    );

    return () => unsubscribe();
  }, []);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setShowDropdown(false);
      }
    };

    document.addEventListener('click', handleClickOutside);
    return () => {
      document.removeEventListener('click', handleClickOutside);
    };
  }, []);

  const mergedNotifs = useMemo(() => {
    const backendMap = new Map(
      backendNotifs.map((item) => [String(item.laporan_id), item])
    );

    const merged = realtimeNotifs.map((item) => {
      const backendItem = backendMap.get(String(item.laporan_id));

      return {
        id: backendItem?.id ?? null,
        realtime_id: item.realtime_id,
        laporan_id: item.laporan_id,
        title: item.title || `SOS: ${item.judul || 'Laporan Darurat'}`,
        message: item.message || item.deskripsi || 'Ada laporan baru',
        alamat: item.alamat || '',
        nama: item.user_name || 'Warga',
        created_at: item.created_at || item.mysql_created_at || null,
        is_read: normalizeIsRead(backendItem?.is_read),
        status: item.status || 'pending',
      };
    });

    const backendOnly = backendNotifs
      .filter(
        (item) =>
          !realtimeNotifs.some(
            (rt) => String(rt.laporan_id) === String(item.laporan_id)
          )
      )
      .map((item) => ({
        id: item.id,
        realtime_id: null,
        laporan_id: item.laporan_id,
        title: item.title || 'Notifikasi SOS',
        message: item.message || 'Ada pembaruan laporan',
        alamat: item.alamat || '',
        nama: item.user_name || 'Warga',
        created_at: item.created_at || null,
        is_read: normalizeIsRead(item.is_read),
        status: item.status || 'pending',
      }));

    return [...merged, ...backendOnly].sort((a, b) => {
      const dateA = normalizeDate(a.created_at)?.getTime() || 0;
      const dateB = normalizeDate(b.created_at)?.getTime() || 0;
      return dateB - dateA;
    });
  }, [backendNotifs, realtimeNotifs]);

  const unreadCount = mergedNotifs.filter((n) => !n.is_read).length;

  const markAsRead = useCallback(async (notifId) => {
    if (!notifId) return false;

    try {
      await api.put(`/notifikasi/${notifId}/read`);
      setBackendNotifs((prev) =>
        prev.map((n) => (n.id === notifId ? { ...n, is_read: true } : n))
      );
      return true;
    } catch (err) {
      console.error('Gagal tandai notif dibaca:', err);
      return false;
    }
  }, []);

  const markAllRead = useCallback(async () => {
    try {
      const unread = mergedNotifs.filter((n) => !n.is_read && n.id);

      if (unread.length === 0) return;

      await Promise.all(unread.map((n) => markAsRead(n.id)));

      await fetchBackendNotifikasi();
    } catch (err) {
      console.error('Gagal tandai semua notif:', err);
    }
  }, [mergedNotifs, fetchBackendNotifikasi, markAsRead]);

  const handleNotifClick = async (notif) => {
    if (!notif.is_read && notif.id) {
      await markAsRead(notif.id);
      await fetchBackendNotifikasi();
    }

    setShowDropdown(false);

    if (notif.laporan_id) {
      navigate("/laporan", {
        state: {
          selectedId: notif.laporan_id,
        },
      });
    }
  };

  const formatTime = (val) => {
    const date = normalizeDate(val);
    if (!date) return '';

    const now = new Date();
    const diff = Math.floor((now - date) / 1000);

    if (diff < 60) return `${diff}d lalu`;
    if (diff < 3600) return `${Math.floor(diff / 60)}m lalu`;
    if (diff < 86400) return `${Math.floor(diff / 3600)}j lalu`;
    return date.toLocaleDateString('id-ID');
  };

  return (
    <header style={styles.navbar}>
      <h1 style={styles.title}>{title}</h1>

      <div style={styles.right}>
        <div style={{ position: 'relative' }} ref={dropdownRef}>
          <button
            onClick={() => setShowDropdown((s) => !s)}
            style={styles.bellBtn}
            title="Notifikasi SOS"
          >
            <Bell size={20} color={unreadCount > 0 ? '#ef4444' : '#64748b'} />
            {unreadCount > 0 && (
              <span style={styles.badge}>
                {unreadCount > 9 ? '9+' : unreadCount}
              </span>
            )}
          </button>

          {showDropdown && (
            <div style={styles.dropdown}>
              <div style={styles.dropdownHeader}>
                <span style={styles.dropdownTitle}>Notifikasi SOS</span>
                {unreadCount > 0 && (
                  <button
                    onMouseDown={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                    }}
                    onClick={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                      console.log('TANDAI SEMUA DIKLIK');
                      markAllRead();
                    }}
                    style={styles.markAllBtn}
                  >
                    <CheckCheck size={12} /> Tandai semua
                  </button>
                )}
              </div>

              <div style={{ maxHeight: 340, overflowY: 'auto' }}>
                {mergedNotifs.length === 0 ? (
                  <p style={styles.empty}>Tidak ada notifikasi</p>
                ) : (
                  mergedNotifs.slice(0, 10).map((n) => {
                    const isRead = n.is_read;

                    return (
                      <div
                        key={n.id || n.realtime_id}
                        onClick={() => handleNotifClick(n)}
                        style={{
                          ...styles.notifItem,
                          background: isRead ? '#ffffff' : '#f8fafc',
                        }}
                      >
                        <div
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: 6,
                            marginBottom: 3,
                          }}
                        >
                          <span style={{ fontSize: 14 }}>🚨</span>
                          <p style={styles.notifTitle}>{n.title}</p>
                          {!isRead && <span style={styles.dotUnread} />}
                        </div>

                        <p style={styles.notifMsg}>{n.message}</p>

                        {n.alamat && (
                          <p style={{ ...styles.notifMsg, fontSize: 11 }}>
                            📍 {n.alamat}
                          </p>
                        )}

                        <p style={styles.notifTime}>{formatTime(n.created_at)}</p>
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

function normalizeDate(val) {
  if (!val) return null;

  if (typeof val?.toDate === 'function') {
    return val.toDate();
  }

  const date = new Date(val);
  return Number.isNaN(date.getTime()) ? null : date;
}

function normalizeIsRead(value) {
  return value === true || value === 1 || value === '1';
}

const styles = {
  navbar: {
    height: 64,
    background: '#fff',
    borderBottom: '1px solid #e2e8f0',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: '0 32px',
    position: 'sticky',
    top: 0,
    zIndex: 50,
  },
  title: {
    fontSize: 18,
    fontWeight: 700,
    color: '#0f172a',
    margin: 0,
  },
  right: {
    display: 'flex',
    alignItems: 'center',
    gap: 16,
  },
  bellBtn: {
    position: 'relative',
    background: 'none',
    border: 'none',
    cursor: 'pointer',
    padding: 8,
    borderRadius: 8,
    display: 'flex',
    alignItems: 'center',
  },
  badge: {
    position: 'absolute',
    top: 2,
    right: 2,
    background: '#ef4444',
    color: '#fff',
    fontSize: 9,
    fontWeight: 700,
    borderRadius: 999,
    minWidth: 16,
    height: 16,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '0 3px',
  },
  dropdown: {
    position: 'absolute',
    top: 52,
    right: 0,
    width: 360,
    background: 'rgba(255,255,255,0.96)',
    backdropFilter: 'blur(12px)',
    borderRadius: 18,
    boxShadow: '0 10px 40px rgba(15,23,42,0.15)',
    border: '1px solid #e2e8f0',
    zIndex: 999,
    overflow: 'hidden',
  },
  dropdownHeader: {
    padding: '16px 18px',
    borderBottom: '1px solid #f1f5f9',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    background: '#ffffff',
  },
  dropdownTitle: {
    fontWeight: 700,
    fontSize: 13,
    color: '#0f172a',
  },
  markAllBtn: {
    display: 'flex',
    alignItems: 'center',
    gap: 4,
    fontSize: 11,
    color: '#64748b',
    background: 'none',
    border: 'none',
    cursor: 'pointer',
    padding: '2px 6px',
    borderRadius: 4,
  },
  empty: {
    padding: '20px 16px',
    color: '#94a3b8',
    fontSize: 13,
    textAlign: 'center',
    margin: 0,
  },
  notifItem: {
    padding: '14px 16px',
    borderBottom: '1px solid #f1f5f9',
    cursor: 'pointer',
    transition: 'all 0.2s ease',
    display: 'flex',
    flexDirection: 'column',
    gap: 4,
  },
  notifTitle: {
    margin: 0,
    fontWeight: 700,
    fontSize: 14,
    color: '#0f172a',
  },
  notifMsg: {
    margin: 0,
    fontSize: 13,
    color: '#475569',
    lineHeight: 1.5,
  },
  notifTime: {
    marginTop: 4,
    fontSize: 11,
    color: '#94a3b8',
    fontWeight: 500,
  },
  dotUnread: {
    width: 6,
    height: 6,
    borderRadius: '50%',
    background: '#ef4444',
    flexShrink: 0,
  },
  userInfo: {
    display: 'flex',
    alignItems: 'center',
    gap: 10,
  },
  avatar: {
    width: 36,
    height: 36,
    borderRadius: 999,
    background: '#0f172a',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },
  userName: {
    margin: 0,
    fontSize: 13,
    fontWeight: 600,
    color: '#0f172a',
  },
  userRole: {
    margin: 0,
    fontSize: 11,
    color: '#94a3b8',
  },
};
