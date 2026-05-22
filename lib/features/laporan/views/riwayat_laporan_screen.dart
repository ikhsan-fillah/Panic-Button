import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/laporan_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../models/laporan_model.dart';
import '../../home/widgets/riwayat_card_widget.dart';

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
    final all = _ctrl.riwayatLaporan.toList();
    if (tabIndex == 0) return all;
    if (tabIndex == 1) {
      return all.where((l) {
        final s = l.status.toLowerCase().trim();
        return !['selesai', 'cancel', 'dibatalkan'].contains(s);
      }).toList();
    }
    return all.where((l) {
      final s = l.status.toLowerCase().trim();
      return ['selesai', 'cancel', 'dibatalkan'].contains(s);
    }).toList();
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
                itemBuilder: (_, idx) => RiwayatCardWidget(
                  laporan: items[idx],
                  index: idx,
                ),
              ),
            );
          }),
        );
      }),
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
