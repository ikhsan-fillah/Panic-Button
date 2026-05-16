# 🚨 Panic Button — Mobile App (Flutter)

Aplikasi pelaporan darurat berbasis mobile untuk warga perumahan. Warga dapat menekan tombol SOS untuk mengirim laporan darurat ke satpam secara realtime.

---

## 📋 Tech Stack

| Layer | Teknologi |
|---|---|
| Mobile | Flutter (Dart) |
| State Management | GetX |
| HTTP Client | Dio |
| Realtime & Push Notif | Firebase (FCM + Firestore) |
| Local Storage | SharedPreferences |
| GPS | Geolocator |
| Image Picker | image_picker |

---

## 🏗️ Struktur Folder

```
lib/
├── core/
│   ├── constants/     # app_constants.dart (base URL, keys)
│   ├── routes/        # app_routes.dart (semua route)
│   ├── services/      # api_service, auth_service, firebase_service
│   └── theme/         # app_theme.dart (warna, helper status)
├── features/
│   ├── auth/          # Login & Register
│   ├── home/          # Home screen + Panic Button
│   ├── laporan/       # Form laporan, riwayat, detail
│   ├── notifikasi/    # Daftar notifikasi
│   └── splash/        # Splash screen
main.dart
```

---

## ⚙️ Setup Project

### 1. Clone & Install Dependencies

```bash
git clone https://github.com/ikhsan-fillah/Panic-Button.git
cd Panic-Button
git checkout mobile
flutter pub get
```

### 2. Ganti Base URL

Buka file `lib/core/constants/app_constants.dart`:

```dart
// Android Emulator (default)
static const String baseUrl = 'http://10.0.2.2:3000/api';

// Device fisik — ganti dengan IP komputer kamu
// static const String baseUrl = 'http://192.168.1.x:3000/api';

// Production
// static const String baseUrl = 'https://your-domain.com/api';
```

> **Catatan:** Backend menggunakan Node.js/Express di port `3000`.

### 3. Setup Firebase (Minta ke Person 4)

1. Minta file `google-services.json` ke **Person 4**
2. Letakkan di `android/app/google-services.json`
3. Pastikan `firebase_options.dart` sudah ada di `lib/`

> Tanpa `google-services.json`, app tetap bisa jalan tapi **notifikasi & realtime tidak aktif**.

### 4. Jalankan App

```bash
# Pastikan emulator/device sudah aktif
flutter run

# Build APK debug
flutter build apk --debug

# Build APK release
flutter build apk --release
```

---

## 📱 Fitur Mobile (Person 1)

| Fitur | Status | Endpoint |
|---|---|---|
| Login | ✅ | `POST /auth/login` |
| Register | ✅ | `POST /auth/register` |
| Logout | ✅ | `POST /auth/logout` |
| Tombol SOS / Panic Button | ✅ | `POST /laporan` |
| GPS otomatis | ✅ | — |
| Upload foto kejadian | ✅ | `POST /laporan/:id/foto` |
| Riwayat laporan | ✅ | `GET /laporan/user` |
| Detail laporan | ✅ | `GET /laporan/:id` |
| Batalkan laporan | ✅ | `PUT /laporan/:id/cancel` |
| Status realtime | ✅ | Firebase `realtime_status` |
| Notifikasi FCM | ✅* | `POST /notifikasi/fcm-token` |
| Daftar notifikasi | ✅ | `GET /notifikasi` |

> *) Membutuhkan `google-services.json` dari Person 4

---

## 🔄 Flow Status Laporan

```
pending → menuju_lokasi → diproses → selesai
                                  ↘ cancel (bisa dari warga saat pending)
```

---

## 🤝 Pembagian Tugas Tim

| Person | Role | Branch |
|---|---|---|
| Person 1 (kamu) | Mobile Developer (Flutter) | `mobile` |
| Person 2 | Web Dashboard Satpam | — |
| Person 3 | Backend & MySQL | `backend` |
| Person 4 | Realtime & Firebase | — |

---

## ⚠️ Checklist Sebelum Demo

- [ ] `google-services.json` sudah ada di `android/app/`
- [ ] Base URL sudah diganti sesuai environment
- [ ] Backend (`npm start`) sudah running di port 3000
- [ ] Database MySQL sudah running & sudah ada data
- [ ] Minimal 1 akun warga sudah terdaftar untuk demo
- [ ] `flutter pub get` sudah dijalankan
- [ ] Test flow: login → tekan SOS → lihat status update

---

## 🐛 Troubleshooting

**App tidak bisa connect ke backend:**
- Pastikan backend running di port 3000
- Cek base URL di `app_constants.dart`
- Untuk device fisik, gunakan IP komputer (bukan `10.0.2.2`)
- Pastikan HP dan komputer satu jaringan WiFi

**Notifikasi tidak muncul:**
- Pastikan `google-services.json` sudah ada
- Minta Person 4 untuk share konfigurasi Firebase
- Cek permission notifikasi di settings HP

**GPS tidak akurat / tidak muncul:**
- Pastikan permission lokasi sudah di-grant
- Nyalakan GPS di HP
- Test di luar ruangan untuk sinyal GPS lebih baik

**Error `401 Unauthorized`:**
- Token expired — coba logout lalu login ulang
- Pastikan backend berjalan normal
