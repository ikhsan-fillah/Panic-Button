import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
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

  // GPS
  final RxDouble currentLat = 0.0.obs;
  final RxDouble currentLng = 0.0.obs;
  final RxString currentAddress = ''.obs;
  final RxBool isLoadingGPS = false.obs;

  // Form
  final RxString selectedPriority = 'tinggi'.obs;
  XFile? selectedPhoto;
  final RxString photoPath = ''.obs;

  // Realtime
  final RxString realtimeStatus = ''.obs;
  final RxBool isFirebaseConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
    getLocation();
    // Bind Firebase connectivity
    ever(_firebase.isConnected, (connected) {
      isFirebaseConnected.value = connected;
    });
  }

  // ----------------------------------------------------------
  // GPS
  // ----------------------------------------------------------
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
      errorMessage.value = 'Gagal mendapatkan lokasi';
    } finally {
      isLoadingGPS.value = false;
    }
  }

  // ----------------------------------------------------------
  // FOTO
  // ----------------------------------------------------------
  Future<void> pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (file != null) {
      selectedPhoto = file;
      photoPath.value = file.path;
    }
  }

  Future<void> pickPhotoFromGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) {
      selectedPhoto = file;
      photoPath.value = file.path;
    }
  }

  // ----------------------------------------------------------
  // KIRIM LAPORAN SOS
  // ----------------------------------------------------------
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

      // Upload foto jika ada
      if (selectedPhoto != null) await uploadFoto(laporan.id);

      // Update lokasi aktif ke Firebase
      // TODO: ganti dengan userId dari AuthController
      // await _firebase.updateActiveLocation(
      //   userId: authController.user.id,
      //   lat: currentLat.value,
      //   lng: currentLng.value,
      // );

      Get.back();
      Get.snackbar(
        'SOS Terkirim! 🚨',
        'Satpam sedang dihubungi. Tetap tenang.',
        backgroundColor: const Color(0xFF1B5E20),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 4),
      );
      getRiwayat();
    } on DioException catch (e) {
      errorMessage.value = e.response?.data['message'] ?? 'Gagal mengirim laporan';
    } finally {
      isSendingSOS.value = false;
    }
  }

  // ----------------------------------------------------------
  // UPLOAD FOTO
  // ----------------------------------------------------------
  Future<void> uploadFoto(int laporanId) async {
    if (selectedPhoto == null) return;
    try {
      final formData = FormData.fromMap({
        'foto': await MultipartFile.fromFile(
          selectedPhoto!.path,
          filename: 'foto_laporan.jpg',
        ),
      });
      await _api.dio.post('/laporan/$laporanId/foto', data: formData);
    } catch (_) {
      // Silent fail — foto tidak krusial untuk flow SOS
    }
  }

  // ----------------------------------------------------------
  // GET RIWAYAT
  // ----------------------------------------------------------
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

  // ----------------------------------------------------------
  // GET DETAIL LAPORAN + REALTIME LISTENER
  // ----------------------------------------------------------
  Future<void> getLaporan(int id) async {
    isLoading.value = true;
    try {
      final res = await _api.dio.get('/laporan/$id');
      currentLaporan.value = LaporanModel.fromJson(res.data['data'] ?? res.data);

      // Mulai listen perubahan status dari Firebase
      _listenRealtimeStatus(id);
    } on DioException catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void _listenRealtimeStatus(int laporanId) {
    _firebase.listenLaporanStatus(laporanId).listen((DatabaseEvent event) {
      // TODO (Person 4): Sesuaikan dengan struktur data Firebase kamu
      // Contoh jika data = { 'status': 'menuju_lokasi' }
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        final newStatus = data['status'] as String?;
        if (newStatus != null && currentLaporan.value != null) {
          // Update status di UI tanpa fetch ulang ke API
          realtimeStatus.value = newStatus;
          final current = currentLaporan.value!;
          currentLaporan.value = LaporanModel(
            id: current.id,
            judul: current.judul,
            deskripsi: current.deskripsi,
            latitude: current.latitude,
            longitude: current.longitude,
            alamat: current.alamat,
            priority: current.priority,
            status: newStatus, // <-- update status realtime
            foto: current.foto,
            createdAt: current.createdAt,
            updatedAt: current.updatedAt,
          );
        }
      }
    });
  }

  // ----------------------------------------------------------
  // BATALKAN LAPORAN
  // ----------------------------------------------------------
  Future<void> batalkanLaporan(int id) async {
    try {
      await _api.dio.put('/laporan/$id/cancel');
      // Hapus lokasi aktif dari Firebase saat laporan dibatalkan
      // await _firebase.removeActiveLocation(userId);
      getRiwayat();
      Get.back();
      Get.snackbar('Info', 'Laporan berhasil dibatalkan');
    } catch (_) {}
  }
}
