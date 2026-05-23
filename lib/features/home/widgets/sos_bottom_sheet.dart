import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../laporan/controllers/laporan_controller.dart';
import '../../laporan/widgets/foto_picker_widget.dart';

class SOSBottomSheet extends StatefulWidget {
  const SOSBottomSheet({super.key});

  @override
  State<SOSBottomSheet> createState() => _SOSBottomSheetState();
}

class _SOSBottomSheetState extends State<SOSBottomSheet>
    with SingleTickerProviderStateMixin {
  static const double _spaceXs = 8;
  static const double _spaceSm = 12;
  static const double _spaceMd = 16;
  static const double _spaceLg = 20;
  final _formKey = GlobalKey<FormState>();
  final LaporanController _laporanCtrl = Get.find();
  late AnimationController _sheetCtrl;
  late Animation<Offset> _slideAnim;

  int _selectedKategori = -1;
  final _judulCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  String _selectedPriority = 'tinggi';
  final List<Map<String, dynamic>> _priorityOptions = [
    {'value': 'rendah', 'label': 'Rendah', 'color': AppTheme.success},
    {'value': 'sedang', 'label': 'Sedang', 'color': AppTheme.warning},
    {'value': 'tinggi', 'label': 'Tinggi', 'color': AppTheme.danger},
  ];

  @override
  void initState() {
    super.initState();
    _sheetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOut));
    _laporanCtrl.selectedPhoto = null;
    _laporanCtrl.photoPath.value = '';
    _alamatCtrl.text = _laporanCtrl.currentAddress.value;
    if (_laporanCtrl.kategoriList.isEmpty) {
      _laporanCtrl.getKategori();
    }
    _sheetCtrl.forward();
  }

  bool _isKategoriLainnya(Map<String, dynamic> kategori) {
    final nama = (kategori['nama']?.toString() ?? '').toLowerCase().trim();
    return nama == 'lainnya';
  }

  IconData _kategoriIcon(String nama) {
    final key = nama.toLowerCase();
    if (key.contains('curi') || key.contains('keamanan'))
      return Icons.local_police_rounded;
    if (key.contains('bakar')) return Icons.local_fire_department_rounded;
    if (key.contains('kecelakaan')) return Icons.car_crash_rounded;
    if (key.contains('medis')) return Icons.medical_services_rounded;
    if (key.contains('fasilitas')) return Icons.home_repair_service_rounded;
    if (key.contains('hilang')) return Icons.search_rounded;
    if (key.contains('bencana')) return Icons.flood_rounded;
    if (key.contains('kelahi')) return Icons.groups_rounded;
    return Icons.warning_rounded;
  }

  Color _kategoriColor(String nama) {
    final key = nama.toLowerCase();
    if (key.contains('curi') ||
        key.contains('keamanan') ||
        key.contains('kelahi')) {
      return AppTheme.danger;
    }
    if (key.contains('bakar') || key.contains('bencana'))
      return AppTheme.warning;
    if (key.contains('medis')) return AppTheme.info;
    if (key.contains('kecelakaan')) return AppTheme.accent;
    return AppTheme.textMuted;
  }

  @override
  void dispose() {
    _sheetCtrl.dispose();
    _judulCtrl.dispose();
    _deskripsiCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 70);
    if (file != null) {
      _laporanCtrl.selectedPhoto = file;
      _laporanCtrl.photoPath.value = file.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return SlideTransition(
      position: _slideAnim,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF161616),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomPadding),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3A3A),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Title row
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.sos_rounded,
                          color: AppTheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kirim Laporan Darurat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Satpam akan segera dihubungi',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: _spaceLg),
                // Kategori
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Jenis Kejadian',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: _spaceSm),
                Obx(() {
                  final list = _laporanCtrl.kategoriList;
                  if (_laporanCtrl.isLoadingKategori.value && list.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  return SizedBox(
                    height: 216,
                    child: GridView.builder(
                      itemCount: list.length > 10 ? 10 : list.length,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (_, i) {
                        final item = list[i];
                        final nama = item['nama']?.toString() ?? '-';
                        final isSelected = _selectedKategori == i;
                        final color = _kategoriColor(nama);
                        return GestureDetector(
                          onTap: () => setState(() => _selectedKategori = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withOpacity(0.2)
                                  : AppTheme.bgSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? color
                                    : const Color(0xFF2E2E2E),
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.35),
                                        blurRadius: 14,
                                        spreadRadius: 1.5,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _kategoriIcon(nama),
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textMuted,
                                  size: 18,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  nama,
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textMuted,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
                const SizedBox(height: _spaceSm),
                if (_selectedKategori >= 0 &&
                    _selectedKategori < _laporanCtrl.kategoriList.length &&
                    _isKategoriLainnya(
                        _laporanCtrl.kategoriList[_selectedKategori]))
                  Column(
                    children: [
                      TextFormField(
                        controller: _judulCtrl,
                        decoration: InputDecoration(
                          hintText: 'Judul kejadian',
                          filled: true,
                          fillColor: AppTheme.bgSurface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppTheme.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 14),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Judul wajib diisi untuk kategori Lainnya';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: _spaceSm),
                    ],
                  ),
                // Pesan / deskripsi
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Deskripsi (opsional)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: _spaceXs),
                TextField(
                  controller: _deskripsiCtrl,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: 'Ceritakan singkat apa yang terjadi...',
                    counterStyle: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11),
                    filled: true,
                    fillColor: AppTheme.bgSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppTheme.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 14),
                ),
                const SizedBox(height: _spaceSm),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tingkat Prioritas',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: _spaceSm),
                Row(
                  children: _priorityOptions.map((p) {
                    final isSelected = _selectedPriority == p['value'];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(
                            () => _selectedPriority = p['value'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (p['color'] as Color).withOpacity(0.18)
                                : AppTheme.bgSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? p['color'] as Color
                                  : const Color(0xFF3E3E3E),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              p['label'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? p['color'] as Color
                                    : AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: _spaceMd),
                TextField(
                  controller: _alamatCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Alamat kejadian (opsional, default dari GPS)',
                    filled: true,
                    fillColor: AppTheme.bgSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppTheme.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 14),
                ),
                const SizedBox(height: _spaceLg),
                Obx(() => FotoPickerWidget(
                      photoPath: _laporanCtrl.photoPath.value,
                      onPickCamera: () => _pickPhoto(ImageSource.camera),
                      onPickGallery: () => _pickPhoto(ImageSource.gallery),
                      onRemove: () {
                        _laporanCtrl.selectedPhoto = null;
                        _laporanCtrl.photoPath.value = '';
                      },
                    )),
                const SizedBox(height: _spaceMd),
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppTheme.success.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.gps_fixed_rounded,
                              color: AppTheme.success, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _laporanCtrl.currentLat.value == 0
                                  ? 'Lokasi belum siap, pastikan GPS aktif'
                                  : 'Lat ${_laporanCtrl.currentLat.value.toStringAsFixed(6)} | Lng ${_laporanCtrl.currentLng.value.toStringAsFixed(6)}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: _spaceMd),
                Obx(() => _laporanCtrl.errorMessage.value.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.danger.withOpacity(0.3)),
                        ),
                        child: Text(
                          _laporanCtrl.errorMessage.value,
                          style: const TextStyle(
                              color: AppTheme.danger, fontSize: 12),
                        ),
                      )
                    : const SizedBox.shrink()),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          side: const BorderSide(color: Color(0xFF3A3A3A)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Batal',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Obx(() => ElevatedButton(
                            onPressed: (_selectedKategori < 0 ||
                                    _laporanCtrl.isSendingSOS.value)
                                ? null
                                : () {
                                    if (!_formKey.currentState!.validate())
                                      return;
                                    final kategori = _laporanCtrl
                                        .kategoriList[_selectedKategori];
                                    final kategoriId = int.tryParse(
                                          kategori['id'].toString(),
                                        ) ??
                                        0;
                                    if (kategoriId == 0) return;
                                    final kategoriNama =
                                        kategori['nama']?.toString() ??
                                            'Darurat';
                                    final isLainnya =
                                        _isKategoriLainnya(kategori);
                                    final judul = isLainnya
                                        ? _judulCtrl.text.trim()
                                        : kategoriNama;
                                    _laporanCtrl.selectedPriority.value =
                                        _selectedPriority;
                                    _laporanCtrl.kirimLaporan(
                                      kategoriId: kategoriId,
                                      judul: judul,
                                      deskripsi: _deskripsiCtrl.text.trim(),
                                      priority: _selectedPriority,
                                      alamat: _alamatCtrl.text.trim(),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedKategori < 0
                                  ? AppTheme.bgSurface
                                  : AppTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_laporanCtrl.isSendingSOS.value)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                else
                                  const Icon(Icons.send_rounded, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  _laporanCtrl.isSendingSOS.value
                                      ? 'Mengirim...'
                                      : 'Kirim Laporan',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
