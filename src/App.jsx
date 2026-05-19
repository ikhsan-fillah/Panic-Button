import { BrowserRouter, Routes, Route, Navigate, Outlet, useLocation } from 'react-router-dom';
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import { AuthProvider } from './context/AuthContext';
import Sidebar from './components/Sidebar';
import AlarmSOS from './components/AlarmSOS';
import Navbar from './components/Navbar';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Laporan from './pages/Laporan';
import Maps from './pages/Maps';
import Users from './pages/Users';
import Kategori from './pages/Kategori';
import Broadcast from './pages/Broadcast';

const PAGE_TITLES = {
  '/dashboard': 'Dashboard',
  '/laporan':   'Laporan Masuk',
  '/maps':      'Maps Realtime',
  '/users':     'Manajemen User',
  '/kategori':  'Kategori Kejadian',
  '/broadcast': 'Broadcast Darurat',
};

function PrivateLayout() {
  const { pathname } = useLocation();
  const token = localStorage.getItem('token');
  if (!token) return <Navigate to="/login" replace />;
  const title = PAGE_TITLES[pathname] || 'Dashboard';

  return (
    <div style={{ display: 'flex' }}>
      <Sidebar />
      <main style={{ marginLeft: 240, flex: 1, minHeight: '100vh', background: '#f8fafc' }}>
        <Navbar title={title} />
        <Outlet /> 
      </main>
    </div>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <AlarmSOS />
        <ToastContainer position="top-right" theme="colored" closeOnClick pauseOnHover draggable />
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/" element={<Navigate to="/dashboard" replace />} />
          <Route element={<PrivateLayout />}>
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/laporan"   element={<Laporan />} />
            <Route path="/maps"      element={<Maps />} />
            <Route path="/users"     element={<Users />} />
            <Route path="/kategori"  element={<Kategori />} />
            <Route path="/broadcast" element={<Broadcast />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}