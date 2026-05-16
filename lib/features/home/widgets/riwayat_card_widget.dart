import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';

class RiwayatCardWidget extends StatefulWidget {
  final Map<String, dynamic> laporan;
  final int index;

  const RiwayatCardWidget({
    super.key,
    required this.laporan,
    required this.index,
  });

  @override
  State<RiwayatCardWidget> createState() => _RiwayatCardWidgetState();
}

class _RiwayatCardWidgetState extends State<RiwayatCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    // Staggered delay berdasarkan index
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final laporan = widget.laporan;
    final status = (laporan['status'] ?? 'pending') as String;
    final statusColor = AppTheme.statusColor(status);
    final statusLabel = AppTheme.statusLabel(status);
    final judul = (laporan['judul'] ?? 'Laporan Darurat') as String;
    final alamat = (laporan['alamat'] ?? '-') as String;
    final createdAt = (laporan['created_at'] ?? '') as String;
    final priority = (laporan['priority'] ?? 'sedang') as String;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GestureDetector(
          onTap: () => Get.toNamed(
            AppRoutes.detailLaporan,
            arguments: laporan,
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF252525)),
            ),
            child: Row(
              children: [
                // Left icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _priorityIcon(priority),
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        judul,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 11, color: AppTheme.textMuted),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              alamat,
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(createdAt),
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Status badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Icon(Icons.chevron_right_rounded,
                        size: 16, color: AppTheme.textMuted),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _priorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'tinggi':
        return Icons.warning_rounded;
      case 'sedang':
        return Icons.report_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _formatTime(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      return '${diff.inDays} hari lalu';
    } catch (_) {
      return raw;
    }
  }
}
