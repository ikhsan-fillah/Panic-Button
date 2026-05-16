import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/firebase_service.dart';

// Background FCM handler — harus top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message (tidak perlu init Firebase lagi)
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Firebase
  // TODO (Person 4): Pastikan google-services.json sudah ada di android/app/
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (_) {
    // Firebase belum dikonfigurasi — skip dulu
  }

  // Init core services
  await Get.putAsync(() => ApiService().init());
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => FirebaseService().init());

  runApp(const PanicButtonApp());
}

class PanicButtonApp extends StatelessWidget {
  const PanicButtonApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return GetMaterialApp(
      title: 'Panic Button',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: authService.hasSession ? AppRoutes.home : AppRoutes.splash,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}
