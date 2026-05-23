import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../models/laporan_model.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/widgets/riwayat_card_widget.dart';

class RiwayatLaporanScreen extends StatefulWidget {
  const RiwayatLaporanScreen({super.key});

  @override
  State<RiwayatLaporanScreen> createState() => _RiwayatLaporanScreenState();
}

class _RiwayatLaporanScreenState extends State<RiwayatLaporanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  static const List<String> _tabs = ['Semua', 'Aktif', 'Selesai'];

  // Pakai HomeController — sumber data yang sama dengan home screen
  late final HomeController _home;

  @override
  void initState() {
    super.initState();
    _home = Get.find<HomeController>();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    // Refresh data saat halaman dibuka
    _home.refreshRiwayat();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<LaporanModel> _filtered(int tabIndex) {
    final all = List<LaporanModel>.from(_home.riwayatLaporan);
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
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        title: const Text('Riwayat Laporan'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorWeight: 2,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(() {
        if (_home.isLoadingRiwayat.value) {
          return _buildSkeleton();
        }
        return TabBarView(
          controller: _tabCtrl,
          children: List.generate(_tabs.length, (i) {
            final items = _filtered(i);
            if (items.isEmpty) return _buildEmpty(i);
            return RefreshIndicator(
              onRefresh: _home.refreshRiwayat,
              color: AppTheme.primary,
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                itemCount: items.length,
                itemBuilder: (_, idx) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: RiwayatCardWidget(
                    laporan: items[idx],
                    index: idx,
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildEmpty(int tabIndex) {
    const messages = [
      ['Belum ada laporan', 'Laporan yang kamu kirim akan muncul di sini'],
      ['Tidak ada laporan aktif', 'Semua laporan sudah selesai ditangani'],
      ['Belum ada laporan selesai', 'Laporan yang selesai akan muncul di sini'],
    ];
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined,
              size: 64, color: AppTheme.textMuted.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(messages[tabIndex][0],
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(messages[tabIndex][1],
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
