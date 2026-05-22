import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/routes/app_routes.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  final ApiService _api = Get.find();
  final AuthService _auth = Get.find();
  final FirebaseService _firebase = Get.find();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  String _resolveDioError(
    DioException e, {
    required String fallback,
  }) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final msg = data['message']?.toString().trim();
      if (msg != null && msg.isNotEmpty) return msg;
      final err = data['error']?.toString().trim();
      if (err != null && err.isNotEmpty) return err;
    }
    if (data is String && data.trim().isNotEmpty) return data.trim();

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout. Cek internet lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Cek URL API dan koneksi internet.';
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 404) return 'Endpoint tidak ditemukan (404). Cek base URL dan path API.';
        if (code == 500) return 'Server sedang bermasalah (500). Coba beberapa saat lagi.';
        return 'Request gagal (HTTP $code).';
      case DioExceptionType.cancel:
        return 'Request dibatalkan.';
      case DioExceptionType.badCertificate:
        return 'Sertifikat SSL server tidak valid.';
      case DioExceptionType.unknown:
        return 'Terjadi gangguan jaringan. Coba lagi.';
    }
  }

  // Expose user data ke seluruh app
  UserModel? get user => _auth.currentUser.value;
  int? get userId => _auth.userId;
  String? get userName => _auth.userName;

  // ----------------------------------------------------------
  // LOGIN
  // POST /auth/login
  // ----------------------------------------------------------
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await _api.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = res.data['token'];
      final user = UserModel.fromJson(res.data['user']);

      // Simpan token ke Dio & SharedPreferences
      _api.updateToken(token);
      await _auth.saveSession(token, user);

      // Kirim FCM token ke backend setelah login
      await _saveFcmToken();

      Get.offAllNamed(AppRoutes.home);
    } on DioException catch (e) {
      errorMessage.value = _resolveDioError(
        e,
        fallback: 'Login gagal. Coba lagi.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------------------------------------
  // REGISTER
  // POST /auth/register
  // ----------------------------------------------------------
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _api.dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'role': 'warga',
      });
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar(
        'Berhasil! 🎉',
        'Akun berhasil dibuat. Silakan login.',
        duration: const Duration(seconds: 3),
      );
    } on DioException catch (e) {
      errorMessage.value = _resolveDioError(
        e,
        fallback: 'Registrasi gagal. Coba lagi.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------------------------------------
  // LOGOUT
  // POST /auth/logout
  // ----------------------------------------------------------
  Future<void> logout() async {
    try {
      await _api.dio.post('/auth/logout');
    } catch (_) {
      // Tetap logout meski request gagal
    }
    await _auth.clearSession();
    _api.clearToken();
    Get.offAllNamed(AppRoutes.login);
  }

  // ----------------------------------------------------------
  // GET ME — refresh data user dari server
  // GET /auth/me
  // ----------------------------------------------------------
  Future<void> getMe() async {
    try {
      final res = await _api.dio.get('/auth/me');
      final user = UserModel.fromJson(res.data['user'] ?? res.data);
      await _auth.saveSession(_auth.token.value, user);
    } catch (_) {}
  }

  // ----------------------------------------------------------
  // SAVE FCM TOKEN
  // POST /notifikasi/fcm-token (Person 4)
  // ----------------------------------------------------------
  Future<void> _saveFcmToken() async {
    // Inisialisasi FCM dan ambil token dulu
    final fcmToken = await _firebase.initAndGetToken();
    if (fcmToken == null) return;
    try {
      await _api.dio.post('/notifikasi/fcm-token', data: {
        'fcm_token': fcmToken,
      });
    } catch (_) {
      // Silent fail — tidak blokir login flow
    }
  }
}
