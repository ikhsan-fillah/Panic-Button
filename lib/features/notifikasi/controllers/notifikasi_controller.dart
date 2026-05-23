import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../models/notifikasi_model.dart';

class NotifikasiController extends GetxController {
  final ApiService _api = Get.find();

  final RxList<NotifikasiModel> notifikasi = <NotifikasiModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getNotifikasi();
    saveFcmToken();
  }

  Future<void> getNotifikasi() async {
    try {
      isLoading.value = true;
      final res = await _api.dio.get('/notifikasi');
      final List data = res.data is List ? res.data : [];
      notifikasi.value = data.map((e) => NotifikasiModel.fromJson(e)).toList();
      _updateUnreadCount();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markRead(int id) async {
    try {
      await _api.dio.put('/notifikasi/$id/read');
      final idx = notifikasi.indexWhere((n) => n.id == id);
      if (idx != -1) {
        final old = notifikasi[idx];
        notifikasi[idx] = NotifikasiModel(
          id: old.id,
          userId: old.userId,
          laporanId: old.laporanId,
          title: old.title,
          message: old.message,
          isRead: true,
          createdAt: old.createdAt,
        );
        notifikasi.refresh();
        _updateUnreadCount();
      }
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    final unread = notifikasi.where((n) => !n.isRead).toList();
    for (final n in unread) {
      await markRead(n.id);
    }
  }

  Future<void> saveFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();

      print("FCM TOKEN: $token");

      if (token == null) return;

      final res = await _api.dio.post(
        '/notifikasi/fcm-token',
        data: {
          'fcm_token': token,
        },
      );

      print("SAVE TOKEN SUCCESS");
      print(res.data);
    } catch (e) {
      print("SAVE TOKEN ERROR: $e");
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifikasi.where((n) => !n.isRead).length;
  }
}
