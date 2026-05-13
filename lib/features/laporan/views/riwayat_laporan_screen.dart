import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/laporan_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';

class RiwayatLaporanScreen extends StatefulWidget {
  const RiwayatLaporanScreen({super.key});

  @override
  State<RiwayatLaporanScreen> createState() => _RiwayatLaporanScreenState();
}

class _RiwayatLaporanScreenState extends State<RiwayatLaporanScreen> {
  final LaporanController _ctrl = Get.find();

  @override
  void initState() {
    super.initState();
    _ctrl.getRiwayat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Laporan')),
      body: Obx(() {
        if (_ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        }
        if (_ctrl.riwayatLaporan.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: AppTheme.textMuted.withOpacity(0.4)),
                const SizedBox(height: 16),
                const Text('Belum ada laporan',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                const SizedBox(height: 6),
                const Text('Laporan darurat yang kamu kirim akan muncul di sini',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _ctrl.getRiwayat,
          color: AppTheme.primary,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _ctrl.riwayatLaporan.length,
            itemBuilder: (_, i) {
              final l = _ctrl.riwayatLaporan[i];
              final statusColor = AppTheme.statusColor(l.status);
              final statusLabel = AppTheme.statusLabel(l.status);
              final date = DateTime.tryParse(l.createdAt);
              final dateStr = date != null
                  ? DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date)
                  : l.createdAt;
              return GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.detailLaporan, arguments: l.id),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF2E2E2E), width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8, height: 8,
                        margin: const EdgeInsets.only(top: 6, right: 12),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.judul,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                            const SizedBox(height: 4),
                            Text(dateStr, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(statusLabel,
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
