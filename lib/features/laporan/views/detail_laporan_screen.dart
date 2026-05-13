import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/laporan_controller.dart';
import '../../../core/theme/app_theme.dart';

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
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        actions: [
          Obx(() {
            final l = _ctrl.currentLaporan.value;
            if (l != null && l.status == 'pending') {
              return TextButton(
                onPressed: () => _showCancelDialog(l.id),
                child: const Text('Batalkan', style: TextStyle(color: AppTheme.danger)),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (_ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        }
        final l = _ctrl.currentLaporan.value;
        if (l == null) {
          return const Center(child: Text('Laporan tidak ditemukan',
              style: TextStyle(color: AppTheme.textSecondary)));
        }
        final statusColor = AppTheme.statusColor(l.status);
        final statusLabel = AppTheme.statusLabel(l.status);
        final date = DateTime.tryParse(l.createdAt);
        final dateStr = date != null
            ? DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(date)
            : l.createdAt;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                        boxShadow: [BoxShadow(color: statusColor.withOpacity(0.5), blurRadius: 6)],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(statusLabel,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: statusColor)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _infoCard([
                _infoRow('Judul', l.judul),
                if (l.deskripsi != null && l.deskripsi!.isNotEmpty) _infoRow('Deskripsi', l.deskripsi!),
                _infoRow('Prioritas', l.priority.toUpperCase()),
                _infoRow('Waktu', dateStr),
              ]),
              const SizedBox(height: 16),
              _infoCard([
                _infoRow('Koordinat',
                    '${l.latitude.toStringAsFixed(6)}, ${l.longitude.toStringAsFixed(6)}'),
                if (l.alamat != null && l.alamat!.isNotEmpty) _infoRow('Alamat', l.alamat!),
              ], title: 'Lokasi Kejadian'),
              if (l.foto != null && l.foto!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Foto Kejadian',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(l.foto!, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 160, color: AppTheme.bgSurface,
                        child: const Center(child: Icon(Icons.broken_image, color: AppTheme.textMuted)),
                      )),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _infoCard(List<Widget> rows, {String? title}) {
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
          if (title != null) ...[
            Text(title, style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 0.5)),
            const SizedBox(height: 10),
          ],
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted))),
          const Text(': ', style: TextStyle(color: AppTheme.textMuted)),
          Expanded(child: Text(value,
              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  void _showCancelDialog(int id) {
    Get.dialog(AlertDialog(
      backgroundColor: AppTheme.bgCard,
      title: const Text('Batalkan Laporan?', style: TextStyle(color: AppTheme.textPrimary)),
      content: const Text('Laporan yang sudah dibatalkan tidak bisa diaktifkan kembali.',
          style: TextStyle(color: AppTheme.textSecondary)),
      actions: [
        TextButton(onPressed: () => Get.back(),
            child: const Text('Tidak', style: TextStyle(color: AppTheme.textSecondary))),
        TextButton(
          onPressed: () { Get.back(); _ctrl.batalkanLaporan(id); },
          child: const Text('Batalkan', style: TextStyle(color: AppTheme.danger)),
        ),
      ],
    ));
  }
}
