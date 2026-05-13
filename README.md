# Panic Button — Mobile App (Flutter)

Aplikasi mobile untuk warga — bagian dari sistem Panic Button pelaporan darurat perumahan.

## Tech Stack
- **Flutter** (Dart)
- **GetX** — State management & routing
- **Dio** — HTTP client
- **Firebase** (Realtime Database + FCM)
- **Geolocator** — GPS koordinat device
- **Image Picker** — Upload foto kejadian

## Struktur Folder
```
lib/
├── main.dart
├── core/
│   ├── bindings/      # Initial dependency injection
│   ├── constants/     # Base URL, keys
│   ├── routes/        # GetX routing
│   ├── services/      # ApiService, AuthService, FirebaseService
│   └── theme/         # AppTheme, warna, style
└── features/
    ├── splash/        # Splash screen
    ├── auth/          # Login, Register, AuthController
    ├── home/          # Home screen + Panic Button
    └── laporan/       # Form SOS, Riwayat, Detail
```

## Setup
1. Clone repo, checkout branch `mobile`
2. Jalankan `flutter pub get`
3. Tambahkan `google-services.json` (Android) di `android/app/`
4. Ubah `baseUrl` di `lib/core/constants/app_constants.dart` sesuai IP backend
5. Jalankan `flutter run`

## Person 1 Scope
- ✅ Splash screen + auto login check
- ✅ Login & Register
- ✅ Home + Panic Button (animasi pulse)
- ✅ Form laporan darurat + GPS + upload foto
- ✅ Riwayat laporan
- ✅ Detail laporan + realtime status Firebase
- ✅ FCM push notification
