import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../laporan/controllers/laporan_controller.dart';
import '../../notifikasi/controllers/notifikasi_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<LaporanController>(() => LaporanController());
    Get.lazyPut<NotifikasiController>(() => NotifikasiController());
  }
}
