import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'priority_badge.dart';

/// Swipe kiri → hapus, swipe kanan → selesai
/// Tap → buka detail
class TaskCard extends StatelessWidget {
  final Task task;
  final Color warnaMatKul;
  final VoidCallback onTap;
  final VoidCallback onSelesai;
  final VoidCallback onHapus;

  const TaskCard({
    super.key,
    required this.task,
    required this.warnaMatKul,
    required this.onTap,
    required this.onSelesai,
    required this.onHapus,
  });

  String get _labelSisaHari {
    final sisa = task.sisaHari;
    if (sisa < 0) return 'Terlambat ${sisa.abs()}h';
    if (sisa == 0) return 'Hari ini!';
    if (sisa == 1) return 'Besok';
    return '$sisa hari lagi';
  }

  Color get _warnaDeadline {
    final sisa = task.sisaHari;
    if (sisa < 0) return const Color(0xFFDC2626);
    if (sisa == 0) return const Color(0xFFDC2626);
    if (sisa <= 2) return const Color(0xFFEA580C);
    return const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key('task_${task.id}'),
      background: _slideAction(
        const Color(0xFF059669),
        Icons.check_rounded,
        Alignment.centerLeft,
        'Selesai',
      ),
      secondaryBackground: _slideAction(
        const Color(0xFFDC2626),
        Icons.delete_rounded,
        Alignment.centerRight,
        'Hapus',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onSelesai();
          return false;
        } else {
          return await _konfirmasiHapus(context);
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) onHapus();
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outline.withOpacity(0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Color accent bar
                Container(
                  width: 3.5,
                  height: 64,
                  decoration: BoxDecoration(
                    color: warnaMatKul,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.namaTugas,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          PriorityBadge(prioritas: task.prioritas),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Subject
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: warnaMatKul,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            task.mataKuliah,
                            style: TextStyle(
                              fontSize: 12,
                              color: warnaMatKul,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Footer row
                      Row(
                        children: [
                          // Status
                          _StatusPill(status: task.status),
                          const Spacer(),
                          // Deadline
                          Icon(
                            task.isTerlambat
                                ? Icons.error_outline_rounded
                                : Icons.schedule_rounded,
                            size: 13,
                            color: _warnaDeadline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _labelSisaHari,
                            style: TextStyle(
                              color: _warnaDeadline,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      // Subtask progress (if any)
                      if (task.subtasks.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: task.progressSubtask,
                                  minHeight: 4,
                                  backgroundColor:
                                      cs.outline.withOpacity(0.15),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      warnaMatKul),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${task.jumlahSubtaskSelesai}/${task.subtasks.length}',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: cs.onBackground.withOpacity(0.4),
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _slideAction(
      Color color, IconData icon, Alignment alignment, String label) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<bool?> _konfirmasiHapus(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Tugas?'),
        content: Text(
            'Yakin ingin menghapus "${task.namaTugas}"? Kamu bisa membatalkan via notifikasi.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  Color get _color {
    switch (status) {
      case 'selesai':
        return const Color(0xFF059669);
      case 'proses':
        return const Color(0xFF0EA5E9);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  String get _label {
    switch (status) {
      case 'selesai':
        return 'Selesai';
      case 'proses':
        return 'Proses';
      default:
        return 'Belum';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: TextStyle(
            fontSize: 11, color: _color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
