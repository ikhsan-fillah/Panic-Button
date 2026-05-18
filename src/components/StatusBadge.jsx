const statusConfig = {
  pending:         { label: 'Pending',          color: '#f59e0b', bg: '#fef3c7' },
  menuju_lokasi:   { label: 'Menuju Lokasi',    color: '#3b82f6', bg: '#dbeafe' },
  diproses:        { label: 'Diproses',          color: '#8b5cf6', bg: '#ede9fe' },
  selesai:         { label: 'Selesai',           color: '#10b981', bg: '#d1fae5' },
  cancel:          { label: 'Dibatalkan',        color: '#6b7280', bg: '#f3f4f6' },
};

export default function StatusBadge({ status }) {
  const cfg = statusConfig[status] || { label: status, color: '#6b7280', bg: '#f3f4f6' };
  return (
    <span style={{
      padding: '3px 10px', borderRadius: 999, fontSize: 12, fontWeight: 600,
      color: cfg.color, background: cfg.bg,
    }}>
      {cfg.label}
    </span>
  );
}