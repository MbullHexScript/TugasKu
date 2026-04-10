import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/empty_state.dart';

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final selesai = provider.tugasSelesai;

        if (selesai.isEmpty) {
          return const EmptyState(
            ikon: Icons.emoji_events_outlined,
            judul: 'Belum ada tugas selesai',
            subjudul: 'Selesaikan tugas dan tandai sebagai selesai!',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          itemCount: selesai.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) {
            final task = selesai[i];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF059669).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Color(0xFF059669), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.namaTugas,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.lineThrough,
                            color: cs.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          task.mataKuliah,
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withOpacity(0.4)),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert_rounded,
                        size: 20,
                        color: cs.onSurface.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'batal',
                        child: Row(children: [
                          Icon(Icons.replay_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Batalkan Selesai'),
                        ]),
                      ),
                      const PopupMenuItem(
                        value: 'hapus',
                        child: Row(children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus',
                              style: TextStyle(color: Colors.red)),
                        ]),
                      ),
                    ],
                    onSelected: (val) {
                      if (val == 'batal') provider.batalkanSelesai(task);
                      if (val == 'hapus') provider.hapusTugas(task);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
