import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/laporan_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/foto_picker_widget.dart';

class FormLaporanScreen extends StatefulWidget {
  const FormLaporanScreen({super.key});

  @override
  State<FormLaporanScreen> createState() => _FormLaporanScreenState();
}

class _FormLaporanScreenState extends State<FormLaporanScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  final LaporanController _ctrl = Get.find();
  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;

  static const List<Map<String, dynamic>> _priorityOptions = [
    {'value': 'rendah', 'label': 'Rendah', 'color': AppTheme.success},
    {'value': 'sedang', 'label': 'Sedang', 'color': AppTheme.warning},
    {'value': 'tinggi', 'label': 'TINGGI', 'color': AppTheme.danger},
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    // Prefill dari argument SOSBottomSheet jika ada
    final args = Get.arguments;
    if (args != null && args is Map) {
      _judulCtrl.text = args['judul'] ?? '';
      _deskripsiCtrl.text = args['deskripsi'] ?? '';
      if (args['priority'] != null) {
        _ctrl.selectedPriority.value = args['priority'];
      }
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _deskripsiCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 70);
    if (file != null) {
      _ctrl.selectedPhoto = file;
      _ctrl.photoPath.value = file.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        title: const Text('Laporan Darurat'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnim,
          child: FadeTransition(
            opacity: _animCtrl,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GPS Card
                    Obx(() => _buildGPSCard()),
                    const SizedBox(height: 20),

                    // Judul
                    TextFormField(
                      controller: _judulCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Judul Kejadian *',
                        hintText: 'Contoh: Ada pencuri di blok A',
                        prefixIcon: Icon(Icons.title, color: AppTheme.textMuted),
                      ),
                      validator: (v) => v!.isEmpty ? 'Judul wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // Deskripsi
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

                    // Prioritas
                    const Text(
                      'Tingkat Prioritas',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
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
                                color: isSelected
                                    ? (p['color'] as Color).withOpacity(0.18)
                                    : AppTheme.bgSurface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? p['color'] as Color : const Color(0xFF3E3E3E),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  p['label'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? p['color'] as Color : AppTheme.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )),
                    const SizedBox(height: 20),

                    // Foto
                    const Text(
                      'Foto Kejadian (Opsional)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    Obx(() => FotoPickerWidget(
                      photoPath: _ctrl.photoPath.value,
                      onPickCamera: () => _pickPhoto(ImageSource.camera),
                      onPickGallery: () => _pickPhoto(ImageSource.gallery),
                      onRemove: () {
                        _ctrl.selectedPhoto = null;
                        _ctrl.photoPath.value = '';
                      },
                    )),
                    const SizedBox(height: 28),

                    // Error
                    Obx(() => _ctrl.errorMessage.value.isNotEmpty
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.danger.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppTheme.danger, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_ctrl.errorMessage.value,
                                      style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink()),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() => ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
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
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.send_rounded),
                        label: Text(
                          _ctrl.isSendingSOS.value ? 'Mengirim...' : 'Kirim Laporan SOS',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      )),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGPSCard() {
    if (_ctrl.isLoadingGPS.value) {
      return _gpsContainer(
        color: AppTheme.accent.withOpacity(0.08),
        borderColor: AppTheme.accent.withOpacity(0.25),
        child: const Row(
          children: [
            SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent)),
            SizedBox(width: 10),
            Text('Mendeteksi lokasi GPS...', style: TextStyle(color: AppTheme.accent, fontSize: 13)),
          ],
        ),
      );
    }
    if (_ctrl.currentLat.value == 0) {
      return _gpsContainer(
        color: AppTheme.danger.withOpacity(0.08),
        borderColor: AppTheme.danger.withOpacity(0.25),
        child: Row(
          children: [
            const Icon(Icons.location_off_rounded, color: AppTheme.danger, size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('GPS tidak terdeteksi',
                  style: TextStyle(color: AppTheme.danger, fontSize: 13)),
            ),
            GestureDetector(
              onTap: _ctrl.getLocation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Coba Lagi',
                    style: TextStyle(color: AppTheme.danger, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );
    }
    return _gpsContainer(
      color: AppTheme.success.withOpacity(0.08),
      borderColor: AppTheme.success.withOpacity(0.25),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, color: AppTheme.success, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lokasi Berhasil Terdeteksi',
                    style: TextStyle(color: AppTheme.success, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '${_ctrl.currentLat.value.toStringAsFixed(6)}, ${_ctrl.currentLng.value.toStringAsFixed(6)}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _ctrl.getLocation,
            child: const Icon(Icons.refresh_rounded, color: AppTheme.success, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _gpsContainer({required Color color, required Color borderColor, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}
