import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/notification_log_model.dart';
import '../models/task_model.dart';
import '../services/hive_service.dart';
import 'task_detail_screen.dart';

class NotificationCenterSheet extends StatelessWidget {
  const NotificationCenterSheet({super.key});

  String _formatWaktu(DateTime waktu) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final wDay = DateTime(waktu.year, waktu.month, waktu.day);

    final jam =
        '${waktu.hour.toString().padLeft(2, '0')}:${waktu.minute.toString().padLeft(2, '0')}';

    if (wDay == today) return 'Hari ini, $jam';
    if (wDay == yesterday) return 'Kemarin, $jam';

    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${waktu.day} ${bulan[waktu.month - 1]}, $jam';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1826) : Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurface.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Text(
                  'Notifikasi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    await HiveService.tandaiSemuaNotifDibaca();
                  },
                  child: Text(
                    'Tandai semua dibaca',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: cs.outlineVariant.withOpacity(0.4)),

          // List notifikasi
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            child: ValueListenableBuilder<Box<NotificationLog>>(
              valueListenable: HiveService.getNotifLogBox().listenable(),
              builder: (context, box, _) {
                final now = DateTime.now();
                // Hanya tampilkan log yang sudah "terkirim" (waktu <= now)
                final logs = box.values
                    .where((log) => log.waktu.isBefore(now))
                    .toList()
                  ..sort((a, b) => b.waktu.compareTo(a.waktu));

                if (logs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 52,
                          color: cs.onSurface.withOpacity(0.2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada notifikasi',
                          style: TextStyle(
                            color: cs.onSurface.withOpacity(0.4),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  shrinkWrap: true,
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                    color: cs.outlineVariant.withOpacity(0.3),
                  ),
                  itemBuilder: (context, i) {
                    final log = logs[i];
                    final belumDibaca = !log.sudahDibaca;

                    return InkWell(
                      onTap: () async {
                        // Tandai sebagai dibaca
                        if (!log.sudahDibaca) {
                          log.sudahDibaca = true;
                          await log.save();
                        }
                        // Navigasi ke TaskDetailScreen jika ada taskId
                        if (log.taskId != null && context.mounted) {
                          final task = HiveService.getTaskBox()
                              .get(log.taskId);
                          if (task != null && context.mounted) {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TaskDetailScreen(task: task),
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        color: belumDibaca
                            ? cs.primary.withOpacity(0.07)
                            : Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Dot belum dibaca
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: belumDibaca
                                      ? cs.primary
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log.judul,
                                    style: TextStyle(
                                      fontWeight: belumDibaca
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      fontSize: 14,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    log.pesan,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: cs.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _formatWaktu(log.waktu),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: cs.onSurface.withOpacity(0.4),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Safe area bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
