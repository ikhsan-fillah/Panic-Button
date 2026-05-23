import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../laporan/controllers/laporan_controller.dart';
import '../../notifikasi/controllers/notifikasi_controller.dart';

class HomeController extends GetxController {
  final AuthService _auth = Get.find();
  final FirebaseService _firebase = Get.find();
  final LaporanController _laporan = Get.find();

  String get userName => _auth.currentUser.value?.name ?? 'Warga';

  final RxBool hasActiveAlert = false.obs;
  RxBool get isLoadingRiwayat => _laporan.isLoading;
  RxList get riwayatLaporan => _laporan.riwayatLaporan;

  StreamSubscription? _notifikasiSub;
  StreamSubscription? _realtimeSub; // ← TAMBAH

  @override
  void onInit() {
    super.onInit();
    _listenNotifikasi();
    _listenRealtimeStatus(); // ← TAMBAH
    _laporan.getRiwayat();
    try {
      Get.find<NotifikasiController>().saveFcmToken();
    } catch (_) {}
  }

  @override
  void onClose() {
    _notifikasiSub?.cancel();
    _realtimeSub?.cancel(); // ← TAMBAH
    super.onClose();
  }

  Future<void> refreshRiwayat() => _laporan.getRiwayat();

  void _listenNotifikasi() {
    final uid = _auth.currentUser.value?.id;
    if (uid == null) return;
    _notifikasiSub?.cancel();
    _notifikasiSub = _firebase.listenNotifikasiSOS(uid).listen((event) {
      final data = event.data();
      if (data != null) hasActiveAlert.value = true;
    });
  }

  // ← TAMBAH method ini
  void _listenRealtimeStatus() {
    final uid = _auth.currentUser.value?.id;
    if (uid == null) return;

    _realtimeSub?.cancel();

    // Listen semua dokumen realtime_status milik user ini
    _realtimeSub = _firebase.firestore
        .collection('realtime_status')
        .where('user_id', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        // Hanya trigger saat ada update (bukan saat pertama load)
        if (change.type == DocumentChangeType.modified) {
          final data = change.doc.data();
          if (data == null) continue;

          final title = 'Update Laporan';
          final message = data['message'] ?? 'Status laporan diperbarui';
          final laporanId = data['laporan_id'];

          Get.snackbar(
            title,
            message.toString(),
            backgroundColor: AppTheme.primary.withOpacity(0.95),
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            icon: const Icon(Icons.notifications_rounded, color: Colors.white),
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(12),
            borderRadius: 12,
            onTap: (_) {
              if (laporanId != null) {
                Get.toNamed(
                  AppRoutes.detailLaporan,
                  arguments: laporanId is int
                      ? laporanId
                      : int.tryParse('$laporanId'),
                );
              }
            },
          );

          // Refresh notifikasi list
          try {
            Get.find<NotifikasiController>().getNotifikasi();
          } catch (_) {}
        }
      }
    });
  }
}