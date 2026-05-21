import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/firebase_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (_) {}

  Get.put(ApiService());
  Get.put(AuthService());
  Get.put(FirebaseService());

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
      getPages: AppRoutes.pages,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}
