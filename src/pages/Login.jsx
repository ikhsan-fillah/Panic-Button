import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { toast } from 'react-toastify';
import { Shield, Eye, EyeOff } from 'lucide-react';
import api from '../api/axios';

export default function Login() {
  const [form, setForm] = useState({ email: '', password: '' });
  const [showPw, setShowPw] = useState(false);
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
  e.preventDefault();
  setLoading(true);

  try {
    const response = await api.post('/auth/login', {
      email: form.email,
      password: form.password,
    });

    console.log(response.data);
    const token = response.data.token;
    localStorage.setItem('token', token);
    localStorage.setItem('user', JSON.stringify(response.data.user));
    toast.success('Login berhasil');

    navigate('/dashboard');
  } catch (err) {
    console.log(err);
    toast.error('Login gagal');
  } finally {
    setLoading(false);
  }
};

  return (
    <div style={styles.container}>
      <div style={styles.card}>
        <div style={styles.header}>
          <Shield size={48} color="#ef4444" />
          <h1 style={styles.title}>PanicGuard</h1>
          <p style={styles.subtitle}>Dashboard Monitoring Satpam</p>
        </div>
        <form onSubmit={handleSubmit} style={styles.form}>
          <div style={styles.field}>
            <label style={styles.label}>Email</label>
            <input
              type="email" required style={styles.input}
              value={form.email}
              onChange={e => setForm({ ...form, email: e.target.value })}
              placeholder="satpam@gmail.com"
            />
          </div>
          <div style={styles.field}>
            <label style={styles.label}>Password</label>
            <div style={{ position: 'relative' }}>
              <input
                type={showPw ? 'text' : 'password'} required style={styles.input}
                value={form.password}
                onChange={e => setForm({ ...form, password: e.target.value })}
                placeholder="••••••••"
              />
              <button type="button" onClick={() => setShowPw(!showPw)} style={styles.eyeBtn}>
                {showPw ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </div>
          </div>
          <button type="submit" disabled={loading} style={styles.btn}>
            {loading ? 'Masuk...' : 'Masuk Dashboard'}
          </button>
        </form>
      </div>
    </div>
  );
}

const styles = {
  container: {
    minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center',
    background: 'linear-gradient(135deg, #0f172a 0%, #3768b8 100%)',
  },
  card: {
    background: '#fff', borderRadius: 16, padding: '40px 36px',
    width: '100%', maxWidth: 400, boxShadow: '0 25px 50px rgba(0,0,0,0.3)',
  },
  header: { textAlign: 'center', marginBottom: 32 },
  title: { fontSize: 28, fontWeight: 800, color: '#0f172a', margin: '12px 0 4px' },
  subtitle: { color: '#64748b', fontSize: 14 },
  form: { display: 'flex', flexDirection: 'column', gap: 20 },
  field: { display: 'flex', flexDirection: 'column', gap: 6 },
  label: { fontSize: 13, fontWeight: 600, color: '#374151' },
  input: {
    padding: '10px 14px', border: '1.5px solid #e2e8f0', borderRadius: 8,
    fontSize: 14, outline: 'none', width: '100%', boxSizing: 'border-box',
  },
  eyeBtn: {
    position: 'absolute', right: 12, top: '50%', transform: 'translateY(-50%)',
    background: 'none', border: 'none', cursor: 'pointer', color: '#94a3b8',
  },
  btn: {
    padding: '12px', background: '#30309a', color: '#fff',
    border: 'none', borderRadius: 8, fontSize: 15, fontWeight: 700, cursor: 'pointer',
    marginTop: 4,
  },
};