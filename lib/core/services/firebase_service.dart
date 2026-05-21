import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

// ============================================================
// CATATAN UNTUK PERSON 4:
// Sesuaikan nama collection Firestore berikut:
// - realtime_status/{laporanId}  → status laporan terkini
// - sos_notifications/{userId}   → notifikasi SOS masuk
// - active_locations/{userId}    → lokasi aktif user
// - active_reports/{laporanId}   → laporan aktif
// - emergency_broadcast/{id}     → broadcast darurat
//
// Juga pastikan google-services.json sudah di-share ke Person 1
// dan diletakkan di folder: android/app/google-services.json
// ============================================================

class FirebaseService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? fcmToken;
  final RxBool isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initFCM();
  }

  // ----------------------------------------------------------
  // FCM INITIALIZATION
  // ----------------------------------------------------------
  Future<String?> initAndGetToken() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        fcmToken = await _messaging.getToken();
        return fcmToken;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _initFCM() async {
    await initAndGetToken();

    // Foreground notification handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background notification tap handler
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Terminated state notification
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleNotificationTap(initial);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? 'Notifikasi';
    final body = message.notification?.body ?? '';
    final type = message.data['type'] ?? '';

    // Tampilkan snackbar in-app saat notifikasi masuk
    Get.snackbar(
      title,
      body,
      backgroundColor:
          type == 'sos' ? AppTheme.danger.withOpacity(0.95) : AppTheme.bgCard,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      icon: Icon(
        type == 'sos'
            ? Icons.warning_amber_rounded
            : Icons.notifications_rounded,
        color: Colors.white,
      ),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    final laporanId = _parseLaporanId(message.data['laporan_id']);
    if (laporanId != null) {
      Get.toNamed(AppRoutes.detailLaporan, arguments: laporanId);
      return;
    }
    Get.toNamed(AppRoutes.notifikasi);
  }

  int? _parseLaporanId(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  // ----------------------------------------------------------
  // REALTIME STATUS LISTENER
  // Dipanggil dari LaporanController saat buka detail laporan
  // ----------------------------------------------------------
  Stream<DocumentSnapshot<Map<String, dynamic>>> listenLaporanStatus(
      int laporanId) {
    return _firestore
        .collection('realtime_status')
        .doc(laporanId.toString())
        .snapshots();
  }

  // ----------------------------------------------------------
  // NOTIFIKASI SOS LISTENER
  // ----------------------------------------------------------
  Stream<DocumentSnapshot<Map<String, dynamic>>> listenNotifikasiSOS(
      int userId) {
    return _firestore
        .collection('sos_notifications')
        .doc(userId.toString())
        .snapshots();
  }

  // ----------------------------------------------------------
  // ACTIVE LOCATION UPDATE
  // Update lokasi warga ke Firebase saat SOS aktif
  // ----------------------------------------------------------
  Future<void> updateActiveLocation({
    required int userId,
    required double lat,
    required double lng,
  }) async {
    try {
      // TODO (Person 4): Pastikan path ini sesuai struktur Firebase kamu
      await _firestore
          .collection('active_locations')
          .doc(userId.toString())
          .set({
        'latitude': lat,
        'longitude': lng,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));
    } catch (_) {
      // Silent fail — lokasi tidak krusial untuk flow utama
    }
  }

  // ----------------------------------------------------------
  // REMOVE ACTIVE LOCATION
  // Hapus lokasi dari Firebase saat laporan selesai/cancel
  // ----------------------------------------------------------
  Future<void> removeActiveLocation(int userId) async {
    try {
      await _firestore
          .collection('active_locations')
          .doc(userId.toString())
          .delete();
    } catch (_) {}
  }

  // ----------------------------------------------------------
  // REFRESH FCM TOKEN
  // ----------------------------------------------------------
  Future<String?> refreshToken() async {
    await _messaging.deleteToken();
    fcmToken = await _messaging.getToken();
    return fcmToken;
  }
}
