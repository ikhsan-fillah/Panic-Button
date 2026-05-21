import 'dart:async';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../laporan/controllers/laporan_controller.dart';

class HomeController extends GetxController {
  final AuthService _auth = Get.find();
  final FirebaseService _firebase = Get.find();
  final LaporanController _laporan = Get.find();

  String get userName => _auth.currentUser.value?.name ?? 'Warga';

  final RxBool hasActiveAlert = false.obs;
  RxBool get isLoadingRiwayat => _laporan.isLoading;
  RxList get riwayatLaporan => _laporan.riwayatLaporan;
  StreamSubscription? _notifikasiSub;

  @override
  void onInit() {
    super.onInit();
    _listenNotifikasi();
    _laporan.getRiwayat();
  }

  @override
  void onClose() {
    _notifikasiSub?.cancel();
    super.onClose();
  }

  void _listenNotifikasi() {
    final uid = _auth.currentUser.value?.id;
    if (uid == null) return;
    _notifikasiSub?.cancel();
    _notifikasiSub = _firebase.listenNotifikasiSOS(uid).listen((event) {
      final data = event.data();
      if (data != null) hasActiveAlert.value = true;
    });
  }
}
