import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class StatusTimelineWidget extends StatefulWidget {
  final String currentStatus;
  final String? catatanPetugas;
  const StatusTimelineWidget({
    super.key,
    required this.currentStatus,
    this.catatanPetugas,
  });

  @override
  State<StatusTimelineWidget> createState() => _StatusTimelineWidgetState();
}

class _StatusTimelineWidgetState extends State<StatusTimelineWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  static const List<Map<String, dynamic>> _steps = [
    {'key': 'pending', 'label': 'Laporan Terkirim', 'desc': 'Menunggu respons satpam', 'icon': Icons.send_rounded},
    {'key': 'menuju_lokasi', 'label': 'Satpam Bergerak', 'desc': 'Satpam menuju lokasi kejadian', 'icon': Icons.directions_run_rounded},
    {'key': 'diproses', 'label': 'Sedang Ditangani', 'desc': 'Satpam sedang menangani kejadian', 'icon': Icons.shield_rounded},
    {'key': 'selesai', 'label': 'Selesai', 'desc': 'Kejadian telah ditangani', 'icon': Icons.check_circle_rounded},
  ];

  static const List<String> _statusOrder = [
    'pending', 'menuju_lokasi', 'diproses', 'selesai'
  ];

  int get _currentIndex {
    final idx = _statusOrder.indexOf(widget.currentStatus);
    return idx == -1 ? 0 : idx;
  }

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentStatus == 'cancel') {
      return _buildCancelledState();
    }

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
          const Text(
            'STATUS PENANGANAN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_steps.length, (i) {
            final step = _steps[i];
            final isDone = i <= _currentIndex;
            final isActive = i == _currentIndex;
            final isLast = i == _steps.length - 1;

            return FadeTransition(
              opacity: CurvedAnimation(
                parent: _animCtrl,
                curve: Interval(i * 0.2, 1.0, curve: Curves.easeOut),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 40,
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone
                                ? (isActive ? AppTheme.primary : AppTheme.success)
                                : AppTheme.bgSurface,
                            border: Border.all(
                              color: isDone
                                  ? (isActive ? AppTheme.primary : AppTheme.success)
                                  : const Color(0xFF3E3E3E),
                              width: isActive ? 2 : 1,
                            ),
                            boxShadow: isActive
                                ? [BoxShadow(color: AppTheme.primary.withOpacity(0.35), blurRadius: 10, spreadRadius: 1)]
                                : null,
                          ),
                          child: Icon(
                            step['icon'] as IconData,
                            size: 16,
                            color: isDone ? Colors.white : AppTheme.textMuted,
                          ),
                        ),
                        if (!isLast)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            width: 2,
                            height: 36,
                            color: i < _currentIndex
                                ? AppTheme.success
                                : const Color(0xFF3E3E3E),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 28, top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['label'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                              color: isDone
                                  ? (isActive ? AppTheme.primary : AppTheme.textPrimary)
                                  : AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            (isActive &&
                                    widget.catatanPetugas != null &&
                                    widget.catatanPetugas!.trim().isNotEmpty)
                                ? widget.catatanPetugas!.trim()
                                : step['desc'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDone ? AppTheme.textSecondary : AppTheme.textMuted.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCancelledState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cancel_rounded, color: AppTheme.danger, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Laporan Dibatalkan',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.danger)),
              const SizedBox(height: 2),
              Text('Laporan ini telah dibatalkan oleh warga',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
