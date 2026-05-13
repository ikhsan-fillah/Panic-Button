class AppConstants {
  // Ganti dengan base URL backend Laravel kamu
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Timeout
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // SharedPreferences keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Priority laporan
  static const List<String> priorityOptions = ['rendah', 'sedang', 'tinggi'];
}
