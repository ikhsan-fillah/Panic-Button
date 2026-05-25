import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../laporan/controllers/laporan_controller.dart';
import '../../notifikasi/controllers/notifikasi_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    }
    if (!Get.isRegistered<LaporanController>()) {
      Get.lazyPut<LaporanController>(() => LaporanController(), fenix: true);
    }
    if (!Get.isRegistered<NotifikasiController>()) {
      Get.lazyPut<NotifikasiController>(() => NotifikasiController(), fenix: true);
    }
  }
}
