import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController home = Get.find();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Halo,', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                        Obx(() => Text(home.userName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary))),
                      ],
                    ),
                  ),
                  Obx(() => Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: AppTheme.textPrimary),
                        onPressed: () {},
                      ),
                      if (home.hasActiveAlert.value)
                        Positioned(
                          right: 8, top: 8,
                          child: Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.danger),
                          ),
                        ),
                    ],
                  )),
                  GestureDetector(
                    onTap: () => Get.find<AuthController>().logout(),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.bgSurface,
                        border: Border.all(color: const Color(0xFF3E3E3E), width: 1),
                      ),
                      child: const Icon(Icons.person_outline, color: AppTheme.textSecondary, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildPanicButton(),
                    const SizedBox(height: 32),
                    _buildQuickActions(),
                    const SizedBox(height: 32),
                    _buildInfoCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanicButton() {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.formLaporan),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.9,
            colors: [AppTheme.primary.withOpacity(0.25), AppTheme.bgCard],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
        ),
        child: const Column(
          children: [
            _PulsingSOSButton(),
            SizedBox(height: 20),
            Text('TEKAN UNTUK DARURAT',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 2, color: AppTheme.textSecondary)),
            SizedBox(height: 6),
            Text('Satpam akan segera dihubungi',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _quickActionTile(
            icon: Icons.history_rounded,
            label: 'Riwayat\nLaporan',
            onTap: () => Get.toNamed(AppRoutes.riwayatLaporan),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickActionTile(
            icon: Icons.phone_in_talk_rounded,
            label: 'Hubungi\nSatpam',
            color: AppTheme.info,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _quickActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppTheme.accent,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2E2E2E)),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.secondary.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.secondary, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Gunakan tombol SOS hanya untuk kondisi darurat yang membutuhkan pertolongan segera.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingSOSButton extends StatefulWidget {
  const _PulsingSOSButton();

  @override
  State<_PulsingSOSButton> createState() => _PulsingSOSButtonState();
}

class _PulsingSOSButtonState extends State<_PulsingSOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _opacityAnim = Tween<double>(begin: 0.4, end: 0.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => SizedBox(
        width: 140, height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: _scaleAnim.value,
              child: Container(
                width: 130, height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(_opacityAnim.value),
                ),
              ),
            ),
            Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary,
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 24, spreadRadius: 4),
                ],
              ),
              child: const Center(
                child: Text('SOS',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
