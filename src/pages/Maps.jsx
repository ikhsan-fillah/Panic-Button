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

export default function Maps() {
  const [reports, setReports]   = useState([]);
  const [heatmap, setHeatmap]   = useState([]);

  useEffect(() => {
    api.get('/maps/active-reports').then(res => setReports(res.data.data || res.data || []));
    api.get('/maps/heatmap').then(res => setHeatmap(res.data.data || res.data || []));
    const interval = setInterval(() => {
      api.get('/maps/active-reports').then(res => setReports(res.data.data || res.data || []));
    }, 15000); 
    return () => clearInterval(interval);
  }, []);

  return (
    <div style={{ padding: 32 }}>
      <h2 style={{ fontSize: 22, fontWeight: 700, marginBottom: 20 }}>Maps Realtime Kejadian</h2>
      <div style={{ borderRadius: 12, overflow: 'hidden', height: 520, boxShadow: '0 1px 3px rgba(0,0,0,0.12)' }}>
        <MapContainer
          center={[-7.7956, 110.3695]}
          zoom={13}
          style={{ height: '100%', width: '100%' }}
        >
          <TileLayer
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            attribution='© OpenStreetMap contributors'
          />
          {reports.map(r => (
            <Marker key={r.id} position={[r.latitude, r.longitude]} icon={redIcon}>
              <Popup>
                <b>{r.judul}</b><br />
                {r.alamat}<br />
                Status: {r.status}<br />
                Priority: {r.priority}
              </Popup>
            </Marker>
          ))}
          {heatmap.map((h, i) => (
            <Circle key={i} center={[h.latitude, h.longitude]}
              radius={200} color="#ef4444" fillOpacity={0.2} />
          ))}
        </MapContainer>
      </div>
      <p style={{ color: '#94a3b8', fontSize: 12, marginTop: 8 }}>
        🔴 Titik merah = laporan aktif · Lingkaran = area rawan 
      </p>
    </div>
  );
}