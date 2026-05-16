import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';

class SOSBottomSheet extends StatefulWidget {
  const SOSBottomSheet({super.key});

  @override
  State<SOSBottomSheet> createState() => _SOSBottomSheetState();
}

class _SOSBottomSheetState extends State<SOSBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _sheetCtrl;
  late Animation<Offset> _slideAnim;

  int _selectedKategori = -1;
  final _pesanCtrl = TextEditingController();

  final List<Map<String, dynamic>> _kategoriList = [
    {'icon': Icons.local_police_rounded, 'label': 'Kriminal', 'color': AppTheme.danger},
    {'icon': Icons.local_fire_department_rounded, 'label': 'Kebakaran', 'color': AppTheme.warning},
    {'icon': Icons.medical_services_rounded, 'label': 'Medis', 'color': AppTheme.info},
    {'icon': Icons.car_crash_rounded, 'label': 'Kecelakaan', 'color': AppTheme.accent},
    {'icon': Icons.warning_rounded, 'label': 'Lainnya', 'color': AppTheme.textMuted},
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
    _sheetCtrl.forward();
  }

  @override
  void dispose() {
    _sheetCtrl.dispose();
    _pesanCtrl.dispose();
    super.dispose();
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
            const SizedBox(height: 24),
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_kategoriList.length, (i) {
                final item = _kategoriList[i];
                final isSelected = _selectedKategori == i;
                final color = item['color'] as Color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedKategori = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 58,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.18)
                          : AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : const Color(0xFF2E2E2E),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(item['icon'] as IconData,
                            color: isSelected ? color : AppTheme.textMuted,
                            size: 22),
                        const SizedBox(height: 5),
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? color : AppTheme.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            // Pesan opsional
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Keterangan (opsional)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pesanCtrl,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Ceritakan singkat apa yang terjadi...',
                counterStyle:
                    const TextStyle(color: AppTheme.textMuted, fontSize: 11),
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
            const SizedBox(height: 20),
            // GPS indicator
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppTheme.success.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.gps_fixed_rounded,
                      color: AppTheme.success, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Lokasi GPS akan otomatis disertakan',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                        style: TextStyle(
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _selectedKategori < 0
                        ? null
                        : () {
                            Get.back();
                            Get.toNamed(
                              AppRoutes.formLaporan,
                              arguments: {
                                'kategori_index': _selectedKategori,
                                'kategori_nama': _kategoriList[_selectedKategori]['label'],
                                'pesan': _pesanCtrl.text.trim(),
                              },
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Kirim Laporan',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
