# Panic Button - Mobile App (Flutter)

Aplikasi pelaporan darurat berbasis mobile untuk warga perumahan. Warga dapat menekan tombol SOS untuk mengirim laporan darurat ke satpam secara realtime.

---

## Tech Stack

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

## Struktur Folder

```text
lib/
|-- core/
|   |-- constants/     # app_constants.dart (base URL, keys)
|   |-- routes/        # app_routes.dart (semua route)
|   |-- services/      # api_service, auth_service, firebase_service
|   `-- theme/         # app_theme.dart
|-- features/
|   |-- auth/          # Login & Register
|   |-- home/          # Home screen + Panic Button
|   |-- laporan/       # Form laporan, riwayat, detail
|   |-- notifikasi/    # Daftar notifikasi
|   `-- splash/        # Splash screen
`-- main.dart
```

---

## Setup Project (Android)

### 1. Clone & Install Dependencies

```bash
git clone https://github.com/ikhsan-fillah/Panic-Button.git
cd Panic-Button
git checkout mobile
flutter pub get
```

### 2. Ganti Base URL Backend

Edit file `lib/core/constants/app_constants.dart`:

```dart
// Android Emulator (default)
static const String baseUrl = 'http://10.0.2.2:3000/api';

// Device fisik - ganti dengan IP komputer kamu
// static const String baseUrl = 'http://192.168.1.x:3000/api';
```

### 3. Setup Firebase Android

1. Pastikan `android/app/google-services.json` tersedia.
2. Project Firebase yang dipakai: `kelas-if-b-kelompok-16`.
3. Gradle Firebase plugin sudah aktif di:
   - `android/settings.gradle.kts`
   - `android/app/build.gradle.kts`

Catatan:
- Untuk Android-only, app bisa jalan tanpa `firebase_options.dart`.
- `firebase_options.dart` baru wajib saat target Web/iOS/multi-platform.

### 4. Jalankan App

```bash
flutter run
```

---

## Endpoint Backend (Mobile)

| Fitur | Method | Endpoint |
|---|---|---|
| Login | POST | `/api/auth/login` |
| Register | POST | `/api/auth/register` |
| Logout | POST | `/api/auth/logout` |
| Profil login | GET | `/api/auth/me` |
| Kirim SOS/Laporan | POST | `/api/laporan` |
| Upload foto laporan | POST | `/api/laporan/:id/foto` |
| Riwayat laporan user | GET | `/api/laporan/user` |
| Detail laporan | GET | `/api/laporan/:id` |
| Batalkan laporan | PUT | `/api/laporan/:id/cancel` |
| Daftar notifikasi | GET | `/api/notifikasi` |
| Notifikasi dibaca | PUT | `/api/notifikasi/:id/read` |
| Simpan FCM token | POST | `/api/notifikasi/fcm-token` |

---

## Status Fitur Mobile (Person 1)

| Fitur | Status |
|---|---|
| Login/Register/Logout | Selesai |
| Tombol SOS + GPS + upload foto | Selesai |
| Riwayat & detail laporan | Selesai |
| Batalkan laporan | Selesai |
| Realtime status (Firestore `realtime_status`) | Selesai |
| FCM token ke backend | Selesai |
| Daftar notifikasi + mark as read | Selesai |
| Tap notifikasi -> navigasi halaman terkait | Selesai |

---

## Struktur Firestore (koleksi)

```text
active_reports
realtime_status
sos_notifications
emergency_broadcast
active_locations
```

---

## Checklist Sebelum Demo

- [ ] `google-services.json` ada di `android/app/`
- [ ] Base URL backend sesuai environment
- [ ] Backend jalan di port `3000`
- [ ] Database MySQL backend aktif
- [ ] Akun warga tersedia untuk uji login
- [ ] Uji flow: login -> SOS -> update status -> notifikasi

---

## Troubleshooting Singkat

**App tidak connect backend**
- Pastikan backend aktif di port `3000`
- Cek base URL di `app_constants.dart`
- Untuk device fisik, gunakan IP komputer (bukan `10.0.2.2`)

**Notifikasi tidak muncul**
- Pastikan `google-services.json` benar
- Pastikan permission notifikasi di HP diizinkan
- Pastikan endpoint `POST /api/notifikasi/fcm-token` sukses saat login

**401 Unauthorized**
- Coba logout lalu login ulang
- Cek token di backend masih valid
