import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../features/auth/models/user_model.dart';

class AuthService extends GetxService {
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxString token = ''.obs;
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(AppConstants.tokenKey);
    final savedUser = prefs.getString(AppConstants.userKey);

    if (savedToken != null && savedUser != null) {
      token.value = savedToken;
      currentUser.value = UserModel.fromJson(jsonDecode(savedUser));
      isLoggedIn.value = true;
    }
  }

  Future<void> saveSession(String authToken, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, authToken);
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
    token.value = authToken;
    currentUser.value = user;
    isLoggedIn.value = true;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    token.value = '';
    currentUser.value = null;
    isLoggedIn.value = false;
  }

  bool get hasSession => isLoggedIn.value && token.value.isNotEmpty;

  int? get userId => currentUser.value?.id;
  String? get userName => currentUser.value?.name;
  String? get userRole => currentUser.value?.role;
}
