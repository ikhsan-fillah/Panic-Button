import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';

class HomeController extends GetxController {
  final AuthService _auth = Get.find();
  final FirebaseService _firebase = Get.find();

  String get userName => _auth.currentUser.value?.name ?? 'Warga';

  final RxBool hasActiveAlert = false.obs;

  @override
  void onInit() {
    super.onInit();
    _listenNotifikasi();
  }

  void _listenNotifikasi() {
    final uid = _auth.currentUser.value?.id;
    if (uid == null) return;
    _firebase.listenNotifikasi(uid).listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) hasActiveAlert.value = true;
    });
  }
}
