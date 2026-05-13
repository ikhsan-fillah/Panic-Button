import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  String? fcmToken;

  @override
  void onInit() {
    super.onInit();
    _initFCM();
  }

  Future<void> _initFCM() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      fcmToken = await _messaging.getToken();
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle in-app notification
    });
  }

  Stream<DatabaseEvent> listenLaporanStatus(int laporanId) {
    return _database.ref('realtime_status/$laporanId').onValue;
  }

  Stream<DatabaseEvent> listenNotifikasi(int userId) {
    return _database.ref('sos_notifications/$userId').onValue;
  }
}
