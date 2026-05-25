import { useEffect, useState } from 'react';
import { MapContainer, TileLayer, Marker, Popup, Circle } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';
import markerIcon2x from 'leaflet/dist/images/marker-icon-2x.png';
import markerIcon from 'leaflet/dist/images/marker-icon.png';
import markerShadow from 'leaflet/dist/images/marker-shadow.png';
import api from '../api/axios';

delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: markerIcon2x,
  iconUrl: markerIcon,
  shadowUrl: markerShadow,
});

const redIcon = new L.Icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-red.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
  iconSize: [25, 41], iconAnchor: [12, 41], popupAnchor: [1, -34],
});

// Radius lingkaran proporsional dengan bobot, min 150m max 600m
const bobotToRadius = (bobot) => Math.min(150 + bobot * 60, 600);

// Warna lingkaran makin merah sesuai bobot
const bobotToColor = (bobot) => {
  if (bobot >= 5) return '#991b1b';
  if (bobot >= 3) return '#ef4444';
  return '#fca5a5';
};

const priorityCount = (reports, level) => reports.filter(r => r.priority === level).length;

export default function Maps() {
  const [reports, setReports] = useState([]);
  const [heatmap, setHeatmap] = useState([]);
  const [lastUpdate, setLastUpdate] = useState(null);
  const [setPulse] = useState(false);

  const fetchReports = () => {
    api.get('/maps/active-reports').then(res => {
      setReports(res.data.data || res.data || []);
      setLastUpdate(new Date());
      setPulse(true);
      setTimeout(() => setPulse(false), 600);
    });
  };

  useEffect(() => {
    fetchReports();
    api.get('/maps/heatmap').then(res => setHeatmap(res.data.data || res.data || []));
    const interval = setInterval(fetchReports, 15000);
    return () => clearInterval(interval);
  }, []);

  const maxBobot = Math.max(...heatmap.map(h => h.bobot), 1);

  const stats = [
    {
      label: 'Laporan Aktif',
      value: reports.length,
      icon: (
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
          <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
        </svg>
      ),
      color: '#ef4444', bg: '#fef2f2',
    },
    {
      label: 'Prioritas Tinggi',
      value: priorityCount(reports, 'tinggi'),
      icon: (
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
          <path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
          <line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/>
        </svg>
      ),
      color: '#f59e0b', bg: '#fffbeb',
    },
    {
      label: 'Titik Rawan',
      value: maxBobot,
      icon: (
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
          <circle cx="12" cy="12" r="10"/><circle cx="12" cy="12" r="6"/><circle cx="12" cy="12" r="2"/>
        </svg>
      ),
      color: '#8b5cf6', bg: '#f5f3ff',
      suffix: 'laporan',
    },
    {
      label: 'Prioritas Sedang',
      value: priorityCount(reports, 'sedang'),
      icon: (
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
          <circle cx="12" cy="12" r="10"/>
          <line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
        </svg>
      ),
      color: '#0ea5e9', bg: '#f0f9ff',
    },
  ];

  return (
    <div style={s.page}>

      {/* ── Page Header ── */}
      <div style={s.pageHeader}>
        <div>
          <h2 style={s.title}>Maps Realtime Kejadian</h2>
        </div>
        <div style={s.liveChip}>
          <span style={s.liveDot} />
          LIVE
          {lastUpdate && (
            <span style={s.liveTime}>
              · {lastUpdate.toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit', second: '2-digit' })}
            </span>
          )}
        </div>
      </div>

      {/* ── Stat Cards ── */}
      <div style={s.statsRow}>
        {stats.map((stat) => (
          <div key={stat.label} style={s.statCard}>
            <div style={{ ...s.statIcon, color: stat.color, background: stat.bg }}>
              {stat.icon}
            </div>
            <div>
              <p style={s.statValue}>
                {stat.value}
                {stat.suffix && <span style={{ fontSize: 12, fontWeight: 500, color: '#94a3b8', marginLeft: 4 }}>{stat.suffix}</span>}
              </p>
              <p style={s.statLabel}>{stat.label}</p>
            </div>
          </div>
        ))}
      </div>

      {/* ── Map ── */}
      <div style={s.mapWrapper}>

        {/* Legend */}
        <div style={s.legend}>
          <p style={s.legendTitle}>Keterangan</p>
          <div style={s.legendItem}>
            <img
              src="https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-red.png"
              alt="marker"
              style={{ width: 10, height: 16, objectFit: 'contain' }}
            />
            <span style={s.legendText}>Laporan aktif</span>
          </div>
          <div style={s.legendItem}>
            <span style={{ ...s.legendCircle, borderColor: '#fca5a5' }} />
            <span style={s.legendText}>1–2 laporan</span>
          </div>
          <div style={s.legendItem}>
            <span style={{ ...s.legendCircle, borderColor: '#ef4444' }} />
            <span style={s.legendText}>3–4 laporan</span>
          </div>
          <div style={s.legendItem}>
            <span style={{ ...s.legendCircle, borderColor: '#991b1b' }} />
            <span style={s.legendText}>≥ 5 laporan</span>
          </div>
        </div>

        <MapContainer
          center={[-7.7956, 110.3695]}
          zoom={13}
          style={{ height: '100%', width: '100%', zIndex: 1 }}
        >
          <TileLayer
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            attribution='© OpenStreetMap contributors'
          />

          {/* Lingkaran hotspot — radius & warna proporsional dengan bobot */}
          {heatmap.map((h, i) => (
            <Circle
              key={i}
              center={[h.latitude, h.longitude]}
              radius={bobotToRadius(h.bobot)}
              color={bobotToColor(h.bobot)}
              fillOpacity={0.15}
              weight={1.5}
            >
              <Popup>
                <div style={popup.wrap}>
                  <p style={popup.title}>Titik Laporan</p>
                  <p style={popup.row}>
                    Total laporan di titik ini: <b>{h.bobot}</b>
                  </p>
                  <p style={{ ...popup.row, margin: 0, color: '#94a3b8', fontSize: 11 }}>
                    {h.latitude}, {h.longitude}
                  </p>
                </div>
              </Popup>
            </Circle>
          ))}

          {/* Marker laporan aktif */}
          {reports.map(r => (
            <Marker key={r.id} position={[r.latitude, r.longitude]} icon={redIcon}>
              <Popup>
                <div style={popup.wrap}>
                  <p style={popup.title}>{r.judul}</p>
                  <p style={popup.row}><b>Alamat</b><br />{r.alamat}</p>
                  <div style={popup.chips}>
                    <span style={{
                      ...popup.chip,
                      background: r.priority === 'tinggi' ? '#fef2f2' : r.priority === 'sedang' ? '#fffbeb' : '#f8fafc',
                      color: r.priority === 'tinggi' ? '#ef4444' : r.priority === 'sedang' ? '#f59e0b' : '#64748b',
                    }}>
                      {r.priority}
                    </span>
                    <span style={{ ...popup.chip, background: '#f0f9ff', color: '#0ea5e9' }}>
                      {r.status}
                    </span>
                  </div>
                </div>
              </Popup>
            </Marker>
          ))}
        </MapContainer>
      </div>

      <p style={s.footerNote}>
        Data diperbarui otomatis setiap 15 detik · {reports.length} laporan aktif · {heatmap.length} titik historis
      </p>

      <style>{`
        @keyframes livePulse {
          0%, 100% { opacity: 1; transform: scale(1); }
          50%       { opacity: 0.4; transform: scale(0.8); }
        }
      `}</style>
    </div>
  );
}

const s = {
  page: { padding: '32px 36px', maxWidth: 1200, margin: '0 auto' },
  pageHeader: { display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginBottom: 24, flexWrap: 'wrap', gap: 12 },
  title: { fontSize: 20, fontWeight: 700, color: '#0f172a', margin: 0, letterSpacing: '-0.3px' },
  subtitle: { fontSize: 13, color: '#94a3b8', margin: '4px 0 0' },
  liveChip: { display: 'inline-flex', alignItems: 'center', gap: 6, padding: '6px 12px', background: '#fef2f2', border: '1px solid #fecaca', borderRadius: 999, fontSize: 11, fontWeight: 800, color: '#ef4444', letterSpacing: '0.08em' },
  liveDot: { width: 7, height: 7, borderRadius: '50%', background: '#ef4444', display: 'inline-block', animation: 'livePulse 2s infinite' },
  liveTime: { fontWeight: 500, color: '#f87171', letterSpacing: 0 },
  statsRow: { display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 12, marginBottom: 20 },
  statCard: { background: '#fff', borderRadius: 12, padding: '14px 16px', display: 'flex', alignItems: 'center', gap: 14, boxShadow: '0 1px 3px rgba(0,0,0,0.06), 0 0 0 1px rgba(0,0,0,0.04)' },
  statIcon: { width: 40, height: 40, borderRadius: 10, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 },
  statValue: { margin: 0, fontSize: 22, fontWeight: 800, color: '#0f172a', lineHeight: 1 },
  statLabel: { margin: '3px 0 0', fontSize: 11, color: '#94a3b8', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.04em' },
  mapWrapper: { borderRadius: 14, overflow: 'hidden', height: 520, position: 'relative', boxShadow: '0 1px 4px rgba(0,0,0,0.08), 0 0 0 1px rgba(0,0,0,0.05)' },
  legend: { position: 'absolute', bottom: 28, right: 12, zIndex: 999, background: 'rgba(255,255,255,0.96)', backdropFilter: 'blur(6px)', borderRadius: 10, padding: '10px 14px', boxShadow: '0 2px 8px rgba(0,0,0,0.12)', minWidth: 140 },
  legendTitle: { margin: '0 0 8px', fontSize: 10, fontWeight: 800, color: '#94a3b8', textTransform: 'uppercase', letterSpacing: '0.07em' },
  legendItem: { display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6 },
  legendText: { fontSize: 12, color: '#334155', fontWeight: 500 },
  legendCircle: { width: 12, height: 12, borderRadius: '50%', border: '2px solid', background: 'rgba(239,68,68,0.1)', flexShrink: 0 },
  footerNote: { marginTop: 10, fontSize: 12, color: '#cbd5e1', textAlign: 'right' },
};

const popup = {
  wrap: { minWidth: 180, padding: 2 },
  title: { margin: '0 0 8px', fontSize: 14, fontWeight: 700, color: '#0f172a' },
  row: { margin: '0 0 10px', fontSize: 12, color: '#64748b', lineHeight: 1.5 },
  chips: { display: 'flex', gap: 6 },
  chip: { padding: '2px 8px', borderRadius: 999, fontSize: 11, fontWeight: 700, textTransform: 'capitalize' },
};