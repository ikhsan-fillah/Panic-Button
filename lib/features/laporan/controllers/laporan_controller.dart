import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';
import '../models/laporan_model.dart';

class LaporanController extends GetxController {
  final ApiService _api = Get.find();
  final FirebaseService _firebase = Get.find();
  final AuthService _auth = Get.find();

  final RxList<LaporanModel> riwayatLaporan = <LaporanModel>[].obs;
  final Rx<LaporanModel?> currentLaporan = Rx<LaporanModel?>(null);
  final RxString catatanPetugas = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxBool isSendingSOS = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, dynamic>> kategoriList =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingKategori = false.obs;

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
  StreamSubscription? _realtimeStatusSub;
  Worker? _firebaseConnectivityWorker;
  static const List<Map<String, dynamic>> _defaultKategori = [
    {'id': 10, 'nama': 'Lainnya'},
    {'id': 9, 'nama': 'Gangguan Keamanan'},
    {'id': 8, 'nama': 'Kerusakan Fasilitas'},
    {'id': 7, 'nama': 'Kehilangan'},
    {'id': 6, 'nama': 'Bencana Alam'},
    {'id': 5, 'nama': 'Darurat Medis'},
    {'id': 4, 'nama': 'Perkelahian'},
    {'id': 3, 'nama': 'Kecelakaan'},
    {'id': 2, 'nama': 'Kebakaran'},
    {'id': 1, 'nama': 'Pencurian'},
  ];

  @override
  void onInit() {
    super.onInit();
    getLocation();
    getKategori();
    // Bind Firebase connectivity
    _firebaseConnectivityWorker = ever(_firebase.isConnected, (connected) {
      isFirebaseConnected.value = connected;
    });
  }

  @override
  void onClose() {
    _realtimeStatusSub?.cancel();
    _firebaseConnectivityWorker?.dispose();
    super.onClose();
  }

  // ----------------------------------------------------------
  // GET KATEGORI
  // ----------------------------------------------------------
  Future<void> getKategori() async {
    isLoadingKategori.value = true;
    try {
      final res = await _api.dio.get('/kategori');
      final raw = res.data['data'] ?? res.data;
      final fromApi = (raw as List)
          .map((e) {
            final item = e as Map<String, dynamic>;
            return {
              'id': int.tryParse(item['id'].toString()) ?? 0,
              'nama': item['nama']?.toString() ?? '',
            };
          })
          .where(
              (e) => (e['id'] as int) > 0 && (e['nama'] as String).isNotEmpty)
          .toList();

      final map = <int, Map<String, dynamic>>{};
      for (final item in fromApi) {
        map[item['id'] as int] = item;
      }
      for (final item in _defaultKategori) {
        final id = item['id'] as int;
        map.putIfAbsent(id, () => item);
      }

      final merged = map.values.toList()
        ..sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
      final ordered = merged.take(10).toList()
        ..sort((a, b) {
          final aName = (a['nama']?.toString() ?? '').toLowerCase().trim();
          final bName = (b['nama']?.toString() ?? '').toLowerCase().trim();
          if (aName == 'lainnya' && bName != 'lainnya') return 1;
          if (bName == 'lainnya' && aName != 'lainnya') return -1;
          return (b['id'] as int).compareTo(a['id'] as int);
        });
      kategoriList.value = ordered;
    } catch (_) {
      kategoriList.value = List<Map<String, dynamic>>.from(_defaultKategori);
    } finally {
      isLoadingKategori.value = false;
    }
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
    final file =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (file != null) {
      selectedPhoto = file;
      photoPath.value = file.path;
    }
  }

  Future<void> pickPhotoFromGallery() async {
    final picker = ImagePicker();
    final file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) {
      selectedPhoto = file;
      photoPath.value = file.path;
    }
  }

  // ----------------------------------------------------------
  // KIRIM LAPORAN SOS
  // ----------------------------------------------------------
  Future<void> kirimLaporan({
    required int kategoriId,
    required String judul,
    String? deskripsi,
    String? priority,
    String? alamat,
  }) async {
    if (currentLat.value == 0 && currentLng.value == 0) {
      Get.snackbar('Error', 'GPS belum siap, coba lagi');
      return;
    }
    isSendingSOS.value = true;
    errorMessage.value = '';
    try {
      final res = await _api.dio.post('/laporan', data: {
        'kategori_id': kategoriId,
        'judul': judul,
        'deskripsi': deskripsi,
        'latitude': currentLat.value,
        'longitude': currentLng.value,
        'alamat': (alamat != null && alamat.trim().isNotEmpty)
            ? alamat.trim()
            : currentAddress.value,
        'priority': (priority != null && priority.isNotEmpty)
            ? priority
            : selectedPriority.value,
      });
      final laporan = LaporanModel.fromJson(res.data['laporan'] ?? res.data);
      currentLaporan.value = laporan;

      // Upload foto jika ada
      if (selectedPhoto != null) await uploadFoto(laporan.id);
      selectedPhoto = null;
      photoPath.value = '';

      // Sinkronkan lokasi aktif user ke Firebase saat SOS berhasil terkirim.
      final userId = _auth.userId;
      if (userId != null) {
        await _firebase.updateActiveLocation(
          userId: userId,
          lat: currentLat.value,
          lng: currentLng.value,
        );
      }

      Get.back();
      Get.snackbar(
        'SOS Terkirim! 🚨',
        'Satpam sedang dihubungi. Tetap tenang.',
        backgroundColor: const Color(0xFF1B5E20),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 4),
      );
      getRiwayat();
    } on dio.DioException catch (e) {
      errorMessage.value =
          e.response?.data['message'] ?? 'Gagal mengirim laporan';
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
      final formData = dio.FormData.fromMap({
        'foto': await dio.MultipartFile.fromFile(
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
      List list;
      final data = res.data;
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      } else {
        list = [];
      }
      final parsed = <LaporanModel>[];
      for (final item in list) {
        if (item is Map) {
          parsed.add(
            LaporanModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
      riwayatLaporan.value = parsed;
    } on dio.DioException catch (e) {
      errorMessage.value =
          e.response?.data['message'] ?? 'Gagal memuat riwayat';
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------------------------------------
  // GET DETAIL LAPORAN + REALTIME LISTENER
  // ----------------------------------------------------------
  Future<void> getLaporan(int id) async {
    isLoadingDetail.value = true;
    errorMessage.value = '';
    currentLaporan.value = null;
    catatanPetugas.value = '';
    try {
      final res = await _api.dio.get('/laporan/$id');
      final data = res.data;
      Map<String, dynamic>? payload;

      if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is Map<String, dynamic>) {
          payload = inner;
        } else {
          payload = data;
        }
      } else if (data is List &&
          data.isNotEmpty &&
          data.first is Map<String, dynamic>) {
        payload = data.first as Map<String, dynamic>;
      }

      if (payload != null) {
        final laporan = LaporanModel.fromJson(payload);
        currentLaporan.value = laporan;
        await _fetchCatatanPetugas(id);
        _listenRealtimeStatus(id);
      } else {
        errorMessage.value = 'Detail laporan tidak ditemukan';
      }
    } on dio.DioException catch (e) {
      final resData = e.response?.data;
      if (resData is Map<String, dynamic> && resData['message'] != null) {
        errorMessage.value = resData['message'].toString();
      } else {
        errorMessage.value = 'Gagal memuat detail laporan';
      }
    } catch (_) {
      errorMessage.value = 'Terjadi kesalahan saat memuat detail laporan';
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> _fetchCatatanPetugas(int laporanId) async {
    try {
      final res = await _api.dio.get('/penanganan/$laporanId');
      final data = res.data as Map<String, dynamic>;
      final catatan = (data['catatan'] ?? '').toString().trim();

      // Hanya update jika ada isinya
      // Jika kosong = satpam tidak isi catatan = tampil teks default
      if (catatan.isNotEmpty) {
        catatanPetugas.value = catatan;
      } else {
        catatanPetugas.value = '';
      }
    } on dio.DioException catch (e) {
      // 404 = belum ada penanganan = normal
      // catatanPetugas tetap '' = semua step tampil teks default
      catatanPetugas.value = '';
    } catch (_) {
      catatanPetugas.value = '';
    }
  }

  void _listenRealtimeStatus(int laporanId) {
    _realtimeStatusSub?.cancel();
    _realtimeStatusSub =
        _firebase.listenLaporanStatus(laporanId).listen((event) {
      final data = event.data();
      if (data == null) {
        return;
      }

      final newStatus = data['status'] as String?;
      if (newStatus == null) return;
      if (currentLaporan.value == null) return;

      realtimeStatus.value = newStatus;

      // Backend nulis field 'message' ke Firestore, bukan 'catatan'
      final rawMessage = (data['message'] ?? '').toString().trim();

      // Filter teks default sistem, hanya tampilkan catatan custom satpam
      final isDefaultMessage = rawMessage.isEmpty ||
          rawMessage.startsWith('Status laporan diubah') ||
          rawMessage == 'Status laporan diperbarui' ||
          rawMessage == 'Laporan SOS baru diterima';

      catatanPetugas.value = isDefaultMessage ? '' : rawMessage;

      final current = currentLaporan.value!;
      currentLaporan.value = LaporanModel(
        id: current.id,
        userId: current.userId,
        kategoriId: current.kategoriId,
        judul: current.judul,
        deskripsi: current.deskripsi,
        latitude: current.latitude,
        longitude: current.longitude,
        alamat: current.alamat,
        priority: current.priority,
        status: newStatus,
        catatan: isDefaultMessage ? current.catatan : rawMessage,
        foto: current.foto,
        createdAt: current.createdAt,
        updatedAt: current.updatedAt,
      );
    });
  }

  // ----------------------------------------------------------
  // BATALKAN LAPORAN
  // ----------------------------------------------------------
  Future<void> batalkanLaporan(int id) async {
    try {
      await _api.dio.put('/laporan/$id/cancel');
      final userId = _auth.userId;
      if (userId != null) {
        await _firebase.removeActiveLocation(userId);
      }
      getRiwayat();
      Get.back();
      Get.snackbar('Info', 'Laporan berhasil dibatalkan');
    } catch (_) {}
  }
}
