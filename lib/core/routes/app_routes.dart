import 'package:get/get.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/register_screen.dart';
import '../../features/home/views/home_screen.dart';
import '../../features/laporan/views/form_laporan_screen.dart';
import '../../features/laporan/views/detail_laporan_screen.dart';
import '../../features/laporan/views/riwayat_laporan_screen.dart';
import '../../features/notifikasi/views/notifikasi_screen.dart';
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/laporan/bindings/laporan_binding.dart';
import '../../features/notifikasi/bindings/notifikasi_binding.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const formLaporan = '/laporan/buat';
  static const detailLaporan = '/laporan/detail';
  static const riwayatLaporan = '/laporan/riwayat';
  static const notifikasi = '/notifikasi';

  static List<GetPage> get pages => [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: formLaporan,
      page: () => const FormLaporanScreen(),
      binding: LaporanBinding(),
      transition: Transition.upToDown,
    ),
    GetPage(
      name: detailLaporan,
      page: () => const DetailLaporanScreen(),
      binding: LaporanBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: riwayatLaporan,
      page: () => const RiwayatLaporanScreen(),
      binding: LaporanBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: notifikasi,
      page: () => const NotifikasiScreen(),
      binding: NotifikasiBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
