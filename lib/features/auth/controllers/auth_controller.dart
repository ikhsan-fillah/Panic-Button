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
      _api.updateToken(token);
      await _auth.saveSession(token, user);
      if (_firebase.fcmToken != null) {
        await _api.dio.post('/notifikasi/fcm-token', data: {
          'fcm_token': _firebase.fcmToken,
        });
      }
      Get.offAllNamed(AppRoutes.home);
    } on DioException catch (e) {
      errorMessage.value = e.response?.data['message'] ?? 'Login gagal. Coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

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
      Get.snackbar('Berhasil', 'Akun berhasil dibuat. Silahkan login.');
    } on DioException catch (e) {
      errorMessage.value = e.response?.data['message'] ?? 'Registrasi gagal.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.dio.post('/auth/logout');
    } catch (_) {}
    await _auth.clearSession();
    Get.offAllNamed(AppRoutes.login);
  }
}
