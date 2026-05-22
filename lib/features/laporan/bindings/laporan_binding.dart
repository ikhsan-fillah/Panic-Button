import 'package:get/get.dart';
import '../controllers/laporan_controller.dart';

class LaporanBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<LaporanController>()) {
      Get.lazyPut<LaporanController>(() => LaporanController(), fenix: true);
    }
  }
}
