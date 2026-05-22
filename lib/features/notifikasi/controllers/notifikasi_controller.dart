import 'dart:async';
import 'package:flutter/material.dart';
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
  StreamSubscription? _broadcastSub;
  Worker? _authWorker;
  bool _broadcastPrimed = false;
  String? _lastBroadcastKey;

  @override
  void onInit() {
    super.onInit();
    getNotifikasi();
    _listenFirebaseNotifikasi();
    _listenBroadcast();
    saveFcmToken();
    _authWorker = ever(_auth.currentUser, (_) {
      _listenFirebaseNotifikasi();
      _listenBroadcast();
      getNotifikasi();
      saveFcmToken();
    });
  }

  @override
  void onClose() {
    _notifikasiSub?.cancel();
    _broadcastSub?.cancel();
    _authWorker?.dispose();
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
      List list;
      final data = res.data;
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      } else {
        list = [];
      }
      final parsed = list
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      if (parsed.isNotEmpty) {
        notifikasiList.value = parsed;
      }
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

  void _listenBroadcast() {
    _broadcastSub?.cancel();
    _broadcastPrimed = false;
    _broadcastSub = _firebase.listenBroadcast().listen((snapshot) {
      if (snapshot.docs.isEmpty) return;
      final data = snapshot.docs.first.data();
      final pesan =
          (data['pesan'] ?? data['message'] ?? 'Ada pesan darurat dari satpam')
              .toString();
      final judul =
          (data['judul'] ?? data['title'] ?? 'Broadcast Darurat').toString();
      final createdAt = (data['created_at'] ?? DateTime.now().toIso8601String())
          .toString();
      final broadcastId = snapshot.docs.first.id;
      final key = '$broadcastId|$createdAt|$judul|$pesan';

      if (!_broadcastPrimed) {
        _broadcastPrimed = true;
        _lastBroadcastKey = key;
        return;
      }
      if (_lastBroadcastKey == key) return;
      _lastBroadcastKey = key;

      Get.snackbar(
        judul,
        pesan,
        backgroundColor: const Color(0xFFB71C1C).withOpacity(0.95),
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
        icon: const Icon(Icons.campaign_rounded, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );

      final exists = notifikasiList.any(
        (n) =>
            (n['title']?.toString() == judul) &&
            (n['message']?.toString() == pesan) &&
            (n['created_at']?.toString() == createdAt),
      );
      if (!exists) {
        notifikasiList.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch,
          'title': judul,
          'message': pesan,
          'created_at': createdAt,
          'is_read': false,
        });
        _countUnread();
      }

      getNotifikasi();
    });
  }

  // ----------------------------------------------------------
  // KIRIM FCM TOKEN KE BACKEND
  // Endpoint: POST /notifikasi/fcm-token (Person 4 Realtime)
  // ----------------------------------------------------------
  Future<void> saveFcmToken() async {
    final token = _firebase.fcmToken ?? await _firebase.initAndGetToken();
    if (token == null) return;
    try {
      await _api.dio.post('/notifikasi/fcm-token', data: {'fcm_token': token});
    } catch (_) {}
  }
}
