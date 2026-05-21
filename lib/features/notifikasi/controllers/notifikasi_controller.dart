import 'dart:async';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';

class NotifikasiController extends GetxController {
  final ApiService _api = Get.find();
  final FirebaseService _firebase = Get.find();
  final AuthService _auth = Get.find();

  final RxList<Map<String, dynamic>> notifikasiList = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadCount = 0.obs;
  StreamSubscription? _notifikasiSub;

  @override
  void onInit() {
    super.onInit();
    getNotifikasi();
    _listenFirebaseNotifikasi();
  }

  @override
  void onClose() {
    _notifikasiSub?.cancel();
    super.onClose();
  }

  // ----------------------------------------------------------
  // GET NOTIFIKASI dari API
  // Endpoint: GET /notifikasi (Person 3 Backend)
  // ----------------------------------------------------------
  Future<void> getNotifikasi() async {
    isLoading.value = true;
    try {
      final res = await _api.dio.get('/notifikasi');
      final list = (res.data['data'] ?? res.data) as List;
      notifikasiList.value = list.map((e) => e as Map<String, dynamic>).toList();
      _countUnread();
    } on DioException catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------------------------------------
  // MARK AS READ
  // Endpoint: PUT /notifikasi/{id}/read (Person 3 Backend)
  // ----------------------------------------------------------
  Future<void> markAsRead(int id) async {
    try {
      await _api.dio.put('/notifikasi/$id/read');
      final idx = notifikasiList.indexWhere((n) => n['id'] == id);
      if (idx != -1) {
        notifikasiList[idx] = {...notifikasiList[idx], 'is_read': true};
        notifikasiList.refresh();
        _countUnread();
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    final unread = notifikasiList.where((n) => !(n['is_read'] as bool? ?? false));
    for (final n in unread) {
      await markAsRead(n['id']);
    }
  }

  void _countUnread() {
    unreadCount.value =
        notifikasiList.where((n) => !(n['is_read'] as bool? ?? false)).length;
  }

  // ----------------------------------------------------------
  // FIREBASE REALTIME LISTENER
  void _listenFirebaseNotifikasi() {
    // Ambil user id dari AuthService (session global), lalu subscribe realtime.
    final userId = _auth.userId;
    if (userId == null) return;
    _notifikasiSub?.cancel();
    _notifikasiSub = _firebase.listenNotifikasiSOS(userId).listen((event) {
      if (!event.exists) return;
      // Saat ada trigger SOS di Firebase, refresh list dari API.
      getNotifikasi();
    });
  }

  // ----------------------------------------------------------
  // KIRIM FCM TOKEN KE BACKEND
  // Endpoint: POST /notifikasi/fcm-token (Person 4 Realtime)
  // ----------------------------------------------------------
  Future<void> saveFcmToken() async {
    final token = _firebase.fcmToken;
    if (token == null) return;
    try {
      await _api.dio.post('/notifikasi/fcm-token', data: {'fcm_token': token});
    } catch (_) {}
  }
}
