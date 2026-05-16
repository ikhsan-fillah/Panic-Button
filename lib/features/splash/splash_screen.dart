import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _loadingCtrl;

  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulse1;
  late Animation<double> _pulse2;
  late Animation<double> _pulse1Opacity;
  late Animation<double> _pulse2Opacity;
  late Animation<double> _loadingAnim;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.6)),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.5, 1.0)),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _pulse1 = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
    _pulse2 = Tween<double>(begin: 1.0, end: 2.4).animate(
      CurvedAnimation(
          parent: _pulseCtrl, curve: const Interval(0.2, 1.0, curve: Curves.easeOut)),
    );
    _pulse1Opacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
    _pulse2Opacity = Tween<double>(begin: 0.3, end: 0.0).animate(
      CurvedAnimation(
          parent: _pulseCtrl, curve: const Interval(0.2, 1.0, curve: Curves.easeOut)),
    );

    _loadingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _loadingAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingCtrl, curve: Curves.easeInOut),
    );

    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _loadingCtrl.forward();
    });
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    final auth = Get.find<AuthService>();
    if (auth.isLoggedIn.value) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _pulseCtrl.dispose();
    _loadingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([_logoCtrl, _pulseCtrl]),
              builder: (_, __) => Opacity(
                opacity: _fadeAnim.value,
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulse ring 2 (outer)
                      Transform.scale(
                        scale: _pulse2.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary
                                .withOpacity(_pulse2Opacity.value),
                          ),
                        ),
                      ),
                      // Pulse ring 1 (inner)
                      Transform.scale(
                        scale: _pulse1.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary
                                .withOpacity(_pulse1Opacity.value),
                          ),
                        ),
                      ),
                      // Core button
                      Transform.scale(
                        scale: _scaleAnim.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.5),
                                blurRadius: 32,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.sos_rounded,
                            size: 52,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            AnimatedBuilder(
              animation: _logoCtrl,
              builder: (_, __) => Opacity(
                opacity: _textFade.value,
                child: Column(
                  children: [
                    const Text(
                      'PANIC BUTTON',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 5,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sistem Keamanan Perumahan',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),
            // Loading bar
            AnimatedBuilder(
              animation: _loadingCtrl,
              builder: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _loadingAnim.value,
                        backgroundColor: AppTheme.bgSurface,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                        minHeight: 3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Opacity(
                      opacity: _loadingAnim.value,
                      child: const Text(
                        'Memuat sistem...',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
