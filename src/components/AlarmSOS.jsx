import { useEffect, useRef } from 'react';
import { collection, onSnapshot, query, orderBy, limit } from 'firebase/firestore';
import { db } from '../firebase/firebaseConfig';
import { toast } from 'react-toastify';

export default function AlarmSOS() {
  const shownIds = useRef(new Set());
  const isInitialLoad = useRef(true);

  useEffect(() => {
    const q = query(
      collection(db, 'sos_notifications'),
      orderBy('created_at', 'desc'),
      limit(5)
    );

    const unsub = onSnapshot(q, (snap) => {
      if (isInitialLoad.current) {
        snap.docs.forEach(doc => shownIds.current.add(doc.id));
        isInitialLoad.current = false;
        return;
      }

      snap.docChanges().forEach((change) => {
        if (change.type !== 'added') return;

        const id  = change.doc.id;
        const data = change.doc.data();

        if (shownIds.current.has(id)) return;
        shownIds.current.add(id);

        const nama   = data.nama_warga || data.nama || data.user_name || 'Warga';
        const judul  = data.judul || data.title || 'Laporan Darurat';
        const alamat = data.alamat || data.lokasi || '';

        toast.error(
          <div>
            <div style={{ fontWeight: 700, fontSize: 14, marginBottom: 4 }}>
              🚨 SOS MASUK!
            </div>
            <div style={{ fontWeight: 600, marginBottom: 2 }}>{nama}</div>
            <div style={{ fontSize: 12, opacity: 0.9 }}>{judul}</div>
            {alamat && (
              <div style={{ fontSize: 11, opacity: 0.75, marginTop: 2 }}>
                📍 {alamat}
              </div>
            )}
          </div>,
          {
            toastId: `sos-${id}`,   
            autoClose: 10000,
            position: 'top-right',
          }
        );

        try {
          const audio = new Audio('/alarm.mp3');
          audio.play().catch(() => {}); 
        } catch (_) {}
      });
    });

    return () => unsub();
  }, []);

  return null;
}
