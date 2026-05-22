import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../notifikasi/controllers/notifikasi_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';
import '../widgets/sos_bottom_sheet.dart';
import '../widgets/riwayat_card_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController home = Get.find();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(home),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildSOSArea(context),
                    const SizedBox(height: 28),
                    _buildQuickActions(),
                    const SizedBox(height: 28),
                    _buildRiwayatSection(home),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(HomeController home) {
    final NotifikasiController notifCtrl = Get.isRegistered<NotifikasiController>()
        ? Get.find<NotifikasiController>()
        : Get.put(NotifikasiController());
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF1F1F1F), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Halo,',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 2),
                Obx(() => Text(
                      home.userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    )),
              ],
            ),
          ),
          // Notif bell
          Obx(() => GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.notifikasi),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2E2E2E)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.notifications_outlined,
                          color: AppTheme.textSecondary, size: 20),
                      if (notifCtrl.unreadCount.value > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 3,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.danger,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.bgSurface,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              notifCtrl.unreadCount.value > 99
                                  ? '99+'
                                  : '${notifCtrl.unreadCount.value}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                      if (notifCtrl.unreadCount.value <= 0 &&
                          home.hasActiveAlert.value)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.danger,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )),
          const SizedBox(width: 8),
          // Logout
          GestureDetector(
            onTap: () => Get.find<AuthController>().logout(),
            child: Container(
              width: 92,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2E2E2E)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded,
                      color: AppTheme.textSecondary, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Logout',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSArea(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const SOSBottomSheet(),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.85,
            colors: [
              AppTheme.primary.withOpacity(0.2),
              AppTheme.bgCard,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.primary.withOpacity(0.35)),
        ),
        child: const Column(
          children: [
            _TriplePulseSOSButton(),
            SizedBox(height: 22),
            Text(
              'TEKAN UNTUK DARURAT',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.5,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Satpam akan segera dihubungi',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _quickTile(
            icon: Icons.phone_in_talk_rounded,
            label: 'Hubungi',
            sub: 'Satpam pos',
            color: AppTheme.info,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _quickTile(
            icon: Icons.map_outlined,
            label: 'Peta',
            sub: 'Lokasi rawan',
            color: AppTheme.success,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _quickTile({
    required IconData icon,
    required String label,
    required String sub,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatSection(HomeController home) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Laporan Terbaru',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.riwayatLaporan),
              child: const Text(
                'Lihat semua',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(() {
          if (home.isLoadingRiwayat.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primary,
                ),
              ),
            );
          }
          if (home.riwayatLaporan.isEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined,
                        color: AppTheme.textMuted, size: 36),
                    SizedBox(height: 10),
                    Text(
                      'Belum ada laporan',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Semua aman! Tekan SOS jika terjadi darurat.',
                      style:
                          TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: home.riwayatLaporan.length > 3
                ? 3
                : home.riwayatLaporan.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => RiwayatCardWidget(
              laporan: home.riwayatLaporan[index],
              index: index,
            ),
          );
        }),
      ],
    );
  }
}

// ===== Triple Pulse SOS Button =====
class _TriplePulseSOSButton extends StatefulWidget {
  const _TriplePulseSOSButton();

  @override
  State<_TriplePulseSOSButton> createState() => _TriplePulseSOSButtonState();
}

class _TriplePulseSOSButtonState extends State<_TriplePulseSOSButton>
    with TickerProviderStateMixin {
  late AnimationController _ctrl1;
  late AnimationController _ctrl2;
  late AnimationController _ctrl3;

  @override
  void initState() {
    super.initState();
    _ctrl1 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    _ctrl2 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    _ctrl3 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    Future.delayed(const Duration(milliseconds: 400),
        () => mounted ? _ctrl2.forward(from: 0) : null);
    Future.delayed(const Duration(milliseconds: 800),
        () => mounted ? _ctrl3.forward(from: 0) : null);
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    _ctrl3.dispose();
    super.dispose();
  }

  Widget _ring(AnimationController ctrl) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final scale = Tween<double>(begin: 1.0, end: 2.2)
            .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut))
            .value;
        final opacity = Tween<double>(begin: 0.45, end: 0.0)
            .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut))
            .value;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withOpacity(opacity),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _ring(_ctrl1),
          _ring(_ctrl2),
          _ring(_ctrl3),
          // Core
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.55),
                  blurRadius: 28,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'SOS',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
