import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/notifikasi_controller.dart';
import '../models/notifikasi_model.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  late final NotifikasiController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<NotifikasiController>();
    _ctrl.getNotifikasi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        title: const Text('Notifikasi'),
        actions: [
          Obx(() {
            if (_ctrl.unreadCount.value == 0) return const SizedBox.shrink();
            return TextButton(
              onPressed: _ctrl.markAllRead,
              child: const Text(
                'Tandai semua dibaca',
                style: TextStyle(fontSize: 12, color: AppTheme.primary),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (_ctrl.isLoading.value) return _buildSkeleton();
        final items = _ctrl.notifikasi.toList();
        if (items.isEmpty) return _buildEmpty();
        return RefreshIndicator(
          onRefresh: _ctrl.getNotifikasi,
          color: AppTheme.primary,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            itemCount: items.length,
            itemBuilder: (_, idx) => _NotifCard(notif: items[idx], ctrl: _ctrl),
          ),
        );
      }),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_outlined,
              size: 64, color: AppTheme.textMuted.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('Belum ada notifikasi',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Notifikasi akan muncul di sini',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: 6,
      itemBuilder: (_, i) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _shimmer(height: 44, width: 44, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmer(height: 13, width: double.infinity),
                  const SizedBox(height: 6),
                  _shimmer(height: 11, width: 200),
                  const SizedBox(height: 6),
                  _shimmer(height: 10, width: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmer(
      {required double height, required double width, double radius = 4}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final NotifikasiModel notif;
  final NotifikasiController ctrl;

  const _NotifCard({required this.notif, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isBroadcast = notif.laporanId == null;
    final iconColor = isBroadcast ? AppTheme.danger : AppTheme.primary;
    final icon =
        isBroadcast ? Icons.campaign_rounded : Icons.assignment_late_outlined;

    return GestureDetector(
      onTap: () {
        if (!notif.isRead) ctrl.markRead(notif.id);
        if (!isBroadcast && notif.laporanId != null) {
          Get.toNamed(
            AppRoutes.detailLaporan,
            arguments: notif.laporanId,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              notif.isRead ? AppTheme.bgCard : AppTheme.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                notif.isRead ? const Color(0xFF252525) : AppTheme.primary.withOpacity(0.25),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                notif.isRead ? FontWeight.w500 : FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6, top: 2),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(notif.createdAt),
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
