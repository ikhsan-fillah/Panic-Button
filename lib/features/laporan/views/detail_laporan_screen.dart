import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/laporan_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/status_timeline_widget.dart';

class DetailLaporanScreen extends StatefulWidget {
  const DetailLaporanScreen({super.key});

  @override
  State<DetailLaporanScreen> createState() => _DetailLaporanScreenState();
}

class _DetailLaporanScreenState extends State<DetailLaporanScreen> {
  final LaporanController _ctrl = Get.find();

  @override
  void initState() {
    super.initState();
    final int id = Get.arguments as int;
    _ctrl.getLaporan(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        actions: [
          Obx(() {
            final l = _ctrl.currentLaporan.value;
            if (l != null && l.status == 'pending') {
              return TextButton.icon(
                onPressed: () => _showCancelDialog(l.id),
                icon: const Icon(Icons.cancel_outlined, size: 16, color: AppTheme.danger),
                label: const Text('Batalkan', style: TextStyle(color: AppTheme.danger, fontSize: 13)),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (_ctrl.isLoadingDetail.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        }
        final l = _ctrl.currentLaporan.value;
        if (l == null) {
          return const Center(
            child: Text('Laporan tidak ditemukan',
                style: TextStyle(color: AppTheme.textSecondary)),
          );
        }

        final date = DateTime.tryParse(l.createdAt);
        final dateStr = date != null
            ? DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(date)
            : l.createdAt;
        final priorityColor = l.priority == 'tinggi'
            ? AppTheme.danger
            : l.priority == 'sedang'
                ? AppTheme.warning
                : AppTheme.success;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Timeline
              StatusTimelineWidget(currentStatus: l.status),
              const SizedBox(height: 16),

              // Info Laporan
              _sectionCard(
                title: 'INFORMASI LAPORAN',
                children: [
                  _infoRow(Icons.title, 'Judul', l.judul),
                  if (l.deskripsi != null && l.deskripsi!.isNotEmpty)
                    _infoRow(Icons.description_outlined, 'Deskripsi', l.deskripsi!),
                  _infoRowWidget(
                    Icons.flag_rounded,
                    'Prioritas',
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l.priority.toUpperCase(),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: priorityColor),
                      ),
                    ),
                  ),
                  _infoRow(Icons.access_time_rounded, 'Waktu', dateStr),
                ],
              ),
              const SizedBox(height: 14),

              // Lokasi
              _sectionCard(
                title: 'LOKASI KEJADIAN',
                children: [
                  _infoRow(
                    Icons.my_location_rounded,
                    'Koordinat',
                    '${l.latitude.toStringAsFixed(6)}, ${l.longitude.toStringAsFixed(6)}',
                  ),
                  if (l.alamat != null && l.alamat!.isNotEmpty)
                    _infoRow(Icons.place_rounded, 'Alamat', l.alamat!),
                ],
              ),

              // Foto Kejadian
              if (l.foto != null && l.foto!.isNotEmpty) ...[
                const SizedBox(height: 14),
                _sectionCard(
                  title: 'FOTO KEJADIAN',
                  children: [
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        l.foto!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 160,
                            color: AppTheme.bgSurface,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          height: 120,
                          color: AppTheme.bgSurface,
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.broken_image_outlined, color: AppTheme.textMuted, size: 32),
                                SizedBox(height: 6),
                                Text('Foto tidak tersedia',
                                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E2E2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.8)),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted))),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _infoRowWidget(IconData icon, String label, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted))),
          valueWidget,
        ],
      ),
    );
  }

  void _showCancelDialog(int id) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 22),
            SizedBox(width: 8),
            Text('Batalkan Laporan?',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Laporan yang sudah dibatalkan tidak bisa diaktifkan kembali. Yakin ingin melanjutkan?',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tidak', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Get.back();
              _ctrl.batalkanLaporan(id);
            },
            child: const Text('Batalkan Laporan'),
          ),
        ],
      ),
    );
  }
}
