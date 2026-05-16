class AppConstants {
  // ============================================================
  // BASE URL — Minta ke Person 3 untuk URL deployment
  // Development  : 'http://10.0.2.2:3000/api'  (Android emulator)
  // Device fisik : 'http://<IP-komputer>:3000/api'
  // Production   : 'https://your-domain.com/api'
  // CATATAN: Backend pakai Node.js/Express (bukan Laravel), port 3000
  // ============================================================
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Timeout
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // SharedPreferences keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Priority laporan
  static const List<String> priorityOptions = ['rendah', 'sedang', 'tinggi'];

  // Status laporan
  static const List<String> statusFlow = [
    'pending',
    'menuju_lokasi',
    'diproses',
    'selesai',
  ];
}
