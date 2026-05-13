import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/laporan_controller.dart';
import '../../../core/theme/app_theme.dart';

class FormLaporanScreen extends StatefulWidget {
  const FormLaporanScreen({super.key});

  @override
  State<FormLaporanScreen> createState() => _FormLaporanScreenState();
}

class _FormLaporanScreenState extends State<FormLaporanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  final LaporanController _ctrl = Get.find();

  static const List<Map<String, dynamic>> _priorityOptions = [
    {'value': 'rendah', 'label': 'Rendah', 'color': AppTheme.success},
    {'value': 'sedang', 'label': 'Sedang', 'color': AppTheme.warning},
    {'value': 'tinggi', 'label': 'TINGGI', 'color': AppTheme.danger},
  ];

  @override
  void dispose() {
    _judulCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Darurat'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => _buildGPSCard()),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _judulCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Judul Kejadian',
                    hintText: 'Contoh: Ada pencuri di blok A',
                    prefixIcon: Icon(Icons.title, color: AppTheme.textMuted),
                  ),
                  validator: (v) => v!.isEmpty ? 'Judul wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _deskripsiCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi (opsional)',
                    hintText: 'Ceritakan situasi yang terjadi...',
                    prefixIcon: Icon(Icons.description_outlined, color: AppTheme.textMuted),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Tingkat Prioritas',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: 10),
                Obx(() => Row(
                  children: _priorityOptions.map((p) {
                    final isSelected = _ctrl.selectedPriority.value == p['value'];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _ctrl.selectedPriority.value = p['value'],
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? (p['color'] as Color).withOpacity(0.2) : AppTheme.bgSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? p['color'] as Color : AppTheme.bgCard,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(p['label'],
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? p['color'] as Color : AppTheme.textMuted)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),
                const SizedBox(height: 20),
                const Text('Foto Kejadian (Opsional)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: 10),
                Obx(() => _ctrl.photoPath.value.isNotEmpty
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(File(_ctrl.photoPath.value),
                                width: double.infinity, height: 160, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 8, right: 8,
                            child: GestureDetector(
                              onTap: () { _ctrl.selectedPhoto = null; _ctrl.photoPath.value = ''; },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                                child: const Icon(Icons.close, size: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    : GestureDetector(
                        onTap: _ctrl.pickPhoto,
                        child: Container(
                          width: double.infinity, height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.bgSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF3E3E3E)),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, color: AppTheme.textMuted, size: 28),
                              SizedBox(height: 6),
                              Text('Ambil Foto', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                            ],
                          ),
                        ),
                      )),
                const SizedBox(height: 28),
                Obx(() => _ctrl.errorMessage.value.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_ctrl.errorMessage.value,
                            style: const TextStyle(color: AppTheme.danger, fontSize: 13)))
                    : const SizedBox.shrink()),
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton.icon(
                    onPressed: _ctrl.isSendingSOS.value
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              _ctrl.kirimLaporan(
                                judul: _judulCtrl.text.trim(),
                                deskripsi: _deskripsiCtrl.text.trim(),
                              );
                            }
                          },
                    icon: _ctrl.isSendingSOS.value
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded),
                    label: Text(_ctrl.isSendingSOS.value ? 'Mengirim...' : 'Kirim Laporan SOS'),
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGPSCard() {
    if (_ctrl.isLoadingGPS.value) {
      return _gpsCardContainer(
        child: const Row(
          children: [
            SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent)),
            SizedBox(width: 10),
            Text('Mendeteksi lokasi...', style: TextStyle(color: AppTheme.accent, fontSize: 13)),
          ],
        ),
      );
    }
    if (_ctrl.currentLat.value == 0) {
      return _gpsCardContainer(
        child: Row(
          children: [
            const Icon(Icons.location_off, color: AppTheme.danger, size: 18),
            const SizedBox(width: 8),
            const Expanded(child: Text('GPS tidak terdeteksi',
                style: TextStyle(color: AppTheme.danger, fontSize: 13))),
            GestureDetector(
              onTap: _ctrl.getLocation,
              child: const Text('Coba Lagi',
                  style: TextStyle(color: AppTheme.accent, fontSize: 12, decoration: TextDecoration.underline)),
            ),
          ],
        ),
      );
    }
    return _gpsCardContainer(
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppTheme.success, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lokasi Terdeteksi',
                    style: TextStyle(color: AppTheme.success, fontSize: 12, fontWeight: FontWeight.w600)),
                Text(
                  '${_ctrl.currentLat.value.toStringAsFixed(6)}, ${_ctrl.currentLng.value.toStringAsFixed(6)}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gpsCardContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2E2E2E)),
      ),
      child: child,
    );
  }
}
