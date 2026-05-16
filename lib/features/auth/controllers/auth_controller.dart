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
      errorMessage.value = e.response?.data['message'] ?? 'Login gagal. Coba lagi.';
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
      errorMessage.value = e.response?.data['message'] ?? 'Registrasi gagal. Coba lagi.';
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
