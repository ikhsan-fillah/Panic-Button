import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/firebase_service.dart';
import '../models/laporan_model.dart';

class LaporanController extends GetxController {
  final ApiService _api = Get.find();
  final FirebaseService _firebase = Get.find();

  final RxList<LaporanModel> riwayatLaporan = <LaporanModel>[].obs;
  final Rx<LaporanModel?> currentLaporan = Rx<LaporanModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSendingSOS = false.obs;
  final RxString errorMessage = ''.obs;

  final RxDouble currentLat = 0.0.obs;
  final RxDouble currentLng = 0.0.obs;
  final RxString currentAddress = ''.obs;
  final RxBool isLoadingGPS = false.obs;

  final RxString selectedPriority = 'tinggi'.obs;
  XFile? selectedPhoto;
  final RxString photoPath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getLocation();
  }

  Future<void> getLocation() async {
    isLoadingGPS.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        errorMessage.value = 'Layanan GPS tidak aktif';
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        errorMessage.value = 'Izin lokasi ditolak permanen';
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentLat.value = position.latitude;
      currentLng.value = position.longitude;
      currentAddress.value =
          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
    } catch (e) {
      errorMessage.value = 'Gagal mendapatkan lokasi: $e';
    } finally {
      isLoadingGPS.value = false;
    }
  }

  Future<void> pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (file != null) {
      selectedPhoto = file;
      photoPath.value = file.path;
    }
  }

  Future<void> kirimLaporan({required String judul, String? deskripsi}) async {
    if (currentLat.value == 0 && currentLng.value == 0) {
      Get.snackbar('Error', 'GPS belum siap, coba lagi');
      return;
    }
    isSendingSOS.value = true;
    errorMessage.value = '';
    try {
      final res = await _api.dio.post('/laporan', data: {
        'judul': judul,
        'deskripsi': deskripsi,
        'latitude': currentLat.value,
        'longitude': currentLng.value,
        'alamat': currentAddress.value,
        'priority': selectedPriority.value,
      });
      final laporan = LaporanModel.fromJson(res.data['laporan'] ?? res.data);
      currentLaporan.value = laporan;
      if (selectedPhoto != null) await uploadFoto(laporan.id);
      Get.back();
      Get.snackbar('SOS Terkirim!', 'Satpam sedang dihubungi. Tetap tenang.',
          backgroundColor: const Color(0xFF2E7D32),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 4));
      getRiwayat();
    } on DioException catch (e) {
      errorMessage.value = e.response?.data['message'] ?? 'Gagal mengirim laporan';
    } finally {
      isSendingSOS.value = false;
    }
  }

  Future<void> uploadFoto(int laporanId) async {
    if (selectedPhoto == null) return;
    try {
      final formData = FormData.fromMap({
        'foto': await MultipartFile.fromFile(selectedPhoto!.path, filename: 'foto_laporan.jpg'),
      });
      await _api.dio.post('/laporan/$laporanId/foto', data: formData);
    } catch (_) {}
  }

  Future<void> getRiwayat() async {
    isLoading.value = true;
    try {
      final res = await _api.dio.get('/laporan/user');
      final list = (res.data['data'] ?? res.data) as List;
      riwayatLaporan.value = list.map((e) => LaporanModel.fromJson(e)).toList();
    } on DioException catch (e) {
      errorMessage.value = e.response?.data['message'] ?? 'Gagal memuat riwayat';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getLaporan(int id) async {
    isLoading.value = true;
    try {
      final res = await _api.dio.get('/laporan/$id');
      currentLaporan.value = LaporanModel.fromJson(res.data['data'] ?? res.data);
      _firebase.listenLaporanStatus(id).listen((event) {
        // Realtime status update dari Firebase
      });
    } on DioException catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> batalkanLaporan(int id) async {
    try {
      await _api.dio.put('/laporan/$id/cancel');
      getRiwayat();
      Get.back();
      Get.snackbar('Info', 'Laporan berhasil dibatalkan');
    } catch (_) {}
  }
}
