import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import {
  LayoutDashboard, FileText, Map, Users,
  Tag, Radio, LogOut, Shield
} from 'lucide-react';

const menu = [
  { to: '/dashboard', icon: LayoutDashboard, label: 'Dashboard' },
  { to: '/laporan',   icon: FileText,        label: 'Laporan Masuk' },
  { to: '/maps',      icon: Map,             label: 'Maps Realtime' },
  { to: '/users',     icon: Users,           label: 'Manajemen User' },
  { to: '/kategori',  icon: Tag,             label: 'Kategori' },
  { to: '/broadcast', icon: Radio,           label: 'Broadcast Darurat' },
];

export default function Sidebar() {
  const { logout } = useAuth();
  const navigate = useNavigate();
  const handleLogout = async () => {
    await logout();
    navigate('/login');
  };

  return (
    <aside style={styles.sidebar}>
      <div style={styles.logo}>
        <Shield size={28} color="#ef4444" />
        <span style={styles.logoText}>PanicGuard</span>
      </div>
      <nav style={styles.nav}>
        {menu.map(({ to, icon: Icon, label }) => (
          <NavLink
            key={to}
            to={to}
            style={({ isActive }) => ({
              ...styles.link,
              ...(isActive ? styles.activeLink : {}),
            })}
          >
            <Icon size={18} />
            <span>{label}</span>
          </NavLink>
        ))}
      </nav>
      <div style={{ borderTop: '1px solid rgba(255,255,255,0.15)', marginBottom: 8 }} />
      <button onClick={handleLogout} style={styles.logout}>
        <LogOut size={18} />
        <span>Logout</span>
      </button>
    </aside>
  );
}

const styles = {
  sidebar: {
    width: 240, minHeight: '100vh', background: '#516dad',
    display: 'flex', flexDirection: 'column', padding: '24px 16px 24px',
    position: 'fixed', top: 0, left: 0, zIndex: 100,
  },
  logo: {
    display: 'flex', alignItems: 'center', gap: 10,
    marginBottom: 32, paddingLeft: 8,
  },
  logoText: { color: '#f1f5f9', fontSize: 20, fontWeight: 700, letterSpacing: '-0.5px' },
  nav: { display: 'flex', flexDirection: 'column', gap: 4},
  link: {
    display: 'flex', alignItems: 'center', gap: 10,
    padding: '10px 12px', borderRadius: 8, color: '#94a3b8',
    textDecoration: 'none', fontSize: 14, fontWeight: 500, transition: 'all 0.15s',
  },
  activeLink: {
    background: '#2d589c', color: '#f1f5f9',
    borderLeft: '3px solid #291c62', paddingLeft: 9,
  },
  logout: {
    display: 'flex', alignItems: 'center', gap: 10,
    padding: '10px 12px', borderRadius: 8, color: '#ffffff',
    background: 'transparent', border: 'none', cursor: 'pointer',
    fontSize: 14, fontWeight: 500, width: '100%', marginTop: 8,
  },
};