import { useEffect, useState } from 'react';
import api from '../api/axios';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';
import { AlertTriangle, CheckCircle, Clock, TrendingUp } from 'lucide-react';

export default function Dashboard() {
  const [stats, setStats]       = useState(null);
  const [hariIni, setHariIni]   = useState(null);
  const [prioritas, setPrioritas] = useState([]);
  const [loading, setLoading]   = useState(true);

  useEffect(() => {
    Promise.all([
      api.get('/dashboard/statistik'),
      api.get('/dashboard/hari-ini'),
      api.get('/dashboard/prioritas-tinggi'),
    ]).then(([s, h, p]) => {
      setStats(s.data);
      setHariIni(h.data);
      setPrioritas(p.data || []);
    }).finally(() => setLoading(false));
  }, []);

  if (loading) return <p style={{ padding: 32 }}>Memuat data...</p>;

  const cards = [
  { label: 'Total Laporan', value: stats?.total      ?? 0, icon: TrendingUp,   color: '#3b82f6' },
  { label: 'Pending',       value: stats?.pending     ?? 0, icon: Clock,         color: '#f59e0b' },
  { label: 'Diproses',      value: stats?.diproses    ?? 0, icon: AlertTriangle, color: '#8b5cf6' },
  { label: 'Selesai',       value: stats?.selesai     ?? 0, icon: CheckCircle,   color: '#10b981' },
];

  const chartData = [
    { name: 'Pending',       jumlah: stats?.pending         ?? 0 },
    { name: 'Menuju',        jumlah: stats?.menuju_lokasi   ?? 0 },
    { name: 'Diproses',      jumlah: stats?.diproses        ?? 0 },
    { name: 'Selesai',       jumlah: stats?.selesai         ?? 0 },
    { name: 'Cancel',        jumlah: stats?.cancel          ?? 0 },
  ];

  return (
    <div style={{ padding: 32 }}>
      <h2 style={styles.title}>Dashboard Monitoring</h2>
      <p style={styles.sub}>
        Laporan hari ini: <b>{Array.isArray(hariIni) ? hariIni.length : 0}</b> kejadian
      </p>

      <div style={styles.grid}>
        {cards.map(({ label, value, icon: Icon, color }) => (
          <div key={label} style={styles.card}>
            <div style={{ ...styles.iconBox, background: color + '18' }}>
              <Icon size={24} color={color} />
            </div>
            <div>
              <p style={styles.cardLabel}>{label}</p>
              <p style={{ ...styles.cardValue, color }}>{value}</p>
            </div>
          </div>
        ))}
      </div>

      <div style={styles.chartBox}>
        <h3 style={styles.sectionTitle}>Distribusi Status Laporan</h3>
        <ResponsiveContainer width="100%" height={220}>
          <BarChart data={chartData}>
            <XAxis dataKey="name" tick={{ fontSize: 12 }} />
            <YAxis tick={{ fontSize: 12 }} />
            <Tooltip />
            <Bar dataKey="jumlah" fill="#4466ef" radius={[4, 4, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>

      <div style={styles.chartBox}>
        <h3 style={styles.sectionTitle}>⚠️ Laporan Prioritas Tinggi</h3>
        {prioritas.length === 0 ? (
          <p style={{ color: '#94a3b8' }}>Tidak ada laporan prioritas tinggi saat ini.</p>
        ) : (
          <table style={styles.table}>
            <thead>
              <tr>{['ID', 'Judul', 'Alamat', 'Status', 'Waktu'].map(h => (
                <th key={h} style={styles.th}>{h}</th>
              ))}</tr>
            </thead>
            <tbody>
              {prioritas.map(l => (
                <tr key={l.id}>
                  <td style={styles.td}>#{l.id}</td>
                  <td style={styles.td}>{l.judul}</td>
                  <td style={styles.td}>{l.alamat}</td>
                  <td style={styles.td}>{l.status}</td>
                  <td style={styles.td}>{new Date(l.created_at).toLocaleString('id-ID')}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}

const styles = {
  title: { fontSize: 24, fontWeight: 700, color: '#0f172a', marginBottom: 4 },
  sub: { color: '#64748b', marginBottom: 24, fontSize: 14 },
  grid: { display: 'grid', gridTemplateColumns: 'repeat(4,1fr)', gap: 16, marginBottom: 24 },
  card: {
    background: '#fff', borderRadius: 12, padding: '20px 24px',
    display: 'flex', alignItems: 'center', gap: 16,
    boxShadow: '0 1px 3px rgba(0,0,0,0.08)',
  },
  iconBox: { width: 48, height: 48, borderRadius: 12, display: 'flex', alignItems: 'center', justifyContent: 'center' },
  cardLabel: { fontSize: 13, color: '#64748b', margin: 0 },
  cardValue: { fontSize: 28, fontWeight: 800, margin: '2px 0 0' },
  chartBox: { background: '#fff', borderRadius: 12, padding: 24, marginBottom: 24, boxShadow: '0 1px 3px rgba(0,0,0,0.08)' },
  sectionTitle: { fontSize: 16, fontWeight: 700, color: '#0f172a', marginBottom: 16 },
  table: { width: '100%', borderCollapse: 'collapse', fontSize: 13 },
  th: { textAlign: 'left', padding: '8px 12px', background: '#f8fafc', color: '#64748b', fontWeight: 600 },
  td: { padding: '10px 12px', borderBottom: '1px solid #f1f5f9', color: '#1e293b' },
};