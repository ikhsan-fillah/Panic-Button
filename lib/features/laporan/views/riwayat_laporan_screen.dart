import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/laporan_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';
import '../models/laporan_model.dart';

class RiwayatLaporanScreen extends StatefulWidget {
  const RiwayatLaporanScreen({super.key});

  @override
  State<RiwayatLaporanScreen> createState() => _RiwayatLaporanScreenState();
}

class _RiwayatLaporanScreenState extends State<RiwayatLaporanScreen>
    with SingleTickerProviderStateMixin {
  final LaporanController _ctrl = Get.find();
  late TabController _tabCtrl;

  static const List<String> _tabs = ['Semua', 'Aktif', 'Selesai'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _ctrl.getRiwayat();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<LaporanModel> _filtered(int tabIndex) {
    final all = _ctrl.riwayatLaporan;
    if (tabIndex == 0) return all;
    if (tabIndex == 1) return all.where((l) => !['selesai', 'cancel'].contains(l.status)).toList();
    return all.where((l) => ['selesai', 'cancel'].contains(l.status)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Laporan'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorWeight: 2,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(() {
        if (_ctrl.isLoading.value) {
          return _buildSkeleton();
        }
        return TabBarView(
          controller: _tabCtrl,
          children: List.generate(_tabs.length, (i) {
            final items = _filtered(i);
            if (items.isEmpty) return _buildEmpty(i);
            return RefreshIndicator(
              onRefresh: _ctrl.getRiwayat,
              color: AppTheme.primary,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                itemCount: items.length,
                itemBuilder: (_, idx) => _buildCard(items[idx], idx),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildCard(LaporanModel l, int index) {
    final statusColor = AppTheme.statusColor(l.status);
    final statusLabel = AppTheme.statusLabel(l.status);
    final date = DateTime.tryParse(l.createdAt);
    final dateStr = date != null
        ? DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date)
        : l.createdAt;
    final priorityColor = l.priority == 'tinggi'
        ? AppTheme.danger
        : l.priority == 'sedang'
            ? AppTheme.warning
            : AppTheme.success;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + index * 60),
      curve: Curves.easeOut,
      builder: (_, v, child) => Opacity(opacity: v, child: child),
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.detailLaporan, arguments: l.id),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2E2E2E)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(l.judul,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    child: Row(
                      children: [
                        Container(width: 6, height: 6,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: priorityColor)),
                        const SizedBox(width: 4),
                        Text(l.priority.toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: priorityColor)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(dateStr, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(statusLabel,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor)),
                  ),
                  const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(int tabIndex) {
    final messages = [
      'Belum ada laporan\nLaporan yang kamu kirim akan muncul di sini',
      'Tidak ada laporan aktif\nSemua laporan sudah selesai ditangani',
      'Belum ada laporan selesai\nLaporan yang selesai akan muncul di sini',
    ];
    final parts = messages[tabIndex].split('\n');
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: AppTheme.textMuted.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(parts[0],
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(parts[1],
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: 5,
      itemBuilder: (_, i) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmer(height: 16, width: double.infinity),
            const SizedBox(height: 8),
            _shimmer(height: 12, width: 120),
            const SizedBox(height: 12),
            _shimmer(height: 24, width: 80),
          ],
        ),
      ),
    );
  }

  Widget _shimmer({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
