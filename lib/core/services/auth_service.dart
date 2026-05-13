import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/app_constants.dart';
import '../../features/auth/models/user_model.dart';

class AuthService extends GetxService {
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final userData = prefs.getString(AppConstants.userKey);

    if (token != null && userData != null) {
      currentUser.value = UserModel.fromJson(jsonDecode(userData));
      isLoggedIn.value = true;
    }
  }

  Future<void> saveSession(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
    currentUser.value = user;
    isLoggedIn.value = true;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    currentUser.value = null;
    isLoggedIn.value = false;
  }
}
