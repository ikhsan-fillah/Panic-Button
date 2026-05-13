import 'package:get/get.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/register_screen.dart';
import '../../features/home/views/home_screen.dart';
import '../../features/laporan/views/form_laporan_screen.dart';
import '../../features/laporan/views/detail_laporan_screen.dart';
import '../../features/laporan/views/riwayat_laporan_screen.dart';
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/laporan/bindings/laporan_binding.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const formLaporan = '/laporan/buat';
  static const detailLaporan = '/laporan/detail';
  static const riwayatLaporan = '/laporan/riwayat';

  static List<GetPage> get pages => [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen(), binding: AuthBinding()),
    GetPage(name: register, page: () => const RegisterScreen(), binding: AuthBinding()),
    GetPage(name: home, page: () => const HomeScreen(), binding: HomeBinding()),
    GetPage(name: formLaporan, page: () => const FormLaporanScreen(), binding: LaporanBinding()),
    GetPage(name: detailLaporan, page: () => const DetailLaporanScreen(), binding: LaporanBinding()),
    GetPage(name: riwayatLaporan, page: () => const RiwayatLaporanScreen(), binding: LaporanBinding()),
  ];
}
