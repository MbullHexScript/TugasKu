import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/mata_kuliah_provider.dart';
import '../models/task_model.dart';
import 'task_form_screen.dart';
import 'task_detail_screen.dart';
import 'completed_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchCtrl = TextEditingController();
  bool _showSearch = false;
  String _filterPrioritas = 'semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer2<TaskProvider, MataKuliahProvider>(
      builder: (context, taskProv, mkProv, _) {
        // Apply local priority filter
        List<Task> filtered = taskProv.tugasAktif;
        if (_filterPrioritas != 'semua') {
          filtered =
              filtered.where((t) => t.prioritas == _filterPrioritas).toList();
        }

        // Group into: Hari ini / Mendatang
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final hariIni = filtered
            .where((t) =>
                DateTime(t.deadline.year, t.deadline.month, t.deadline.day) ==
                today)
            .toList();
        final mendatang = filtered
            .where((t) =>
                DateTime(t.deadline.year, t.deadline.month, t.deadline.day) !=
                today)
            .toList();

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF0F0D13) : const Color(0xFFF4F3FF),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final ok = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const TaskFormScreen()),
              );
              if (!mounted) return;
              if (ok == true) {
                taskProv.reload();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tugas berhasil disimpan')),
                );
              }
            },
            backgroundColor: cs.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('Tambah Tugas',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          body: NestedScrollView(
            headerSliverBuilder: (ctx, _) => [
              SliverAppBar(
                pinned: false,
                floating: true,
                backgroundColor:
                    isDark ? const Color(0xFF0F0D13) : const Color(0xFFF4F3FF),
                elevation: 0,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: _showSearch
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _searchCtrl,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Cari tugas...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor:
                                isDark ? const Color(0xFF1C1826) : Colors.white,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            prefixIcon:
                                const Icon(Icons.search_rounded, size: 20),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              onPressed: () {
                                setState(() => _showSearch = false);
                                _searchCtrl.clear();
                                taskProv.setSearchQuery('');
                              },
                            ),
                          ),
                          onChanged: taskProv.setSearchQuery,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Icon(Icons.menu_rounded,
                                color: cs.primary, size: 26),
                            const SizedBox(width: 14),
                            Text(
                              'Daftar Tugas',
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(Icons.search_rounded,
                                  color: cs.primary, size: 24),
                              onPressed: () =>
                                  setState(() => _showSearch = true),
                            ),
                            IconButton(
                              icon: Icon(Icons.tune_rounded,
                                  color: cs.primary, size: 24),
                              tooltip: 'Reset Filter',
                              onPressed: () {
                                setState(() => _filterPrioritas = 'semua');
                                taskProv.resetFilter();
                              },
                            ),
                          ],
                        ),
                      ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(44),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: cs.primary,
                      unselectedLabelColor: cs.onSurface.withOpacity(0.45),
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14),
                      unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14),
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(width: 3, color: cs.primary),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(3),
                          topRight: Radius.circular(3),
                        ),
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Aktif'),
                              const SizedBox(width: 6),
                              _TabBadge(
                                  count: taskProv.jumlahAktif,
                                  color: cs.primary),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Selesai'),
                              const SizedBox(width: 6),
                              _TabBadge(
                                  count: taskProv.jumlahSelesai,
                                  color: const Color(0xFF059669)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                // ── Tab Aktif ──────────────────────────────────────
                Column(
                  children: [
                    // Priority filter chips
                    SizedBox(
                      height: 52,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final p in [
                            'semua',
                            'tinggi',
                            'sedang',
                            'rendah'
                          ])
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _FilterChip(
                                label: p == 'semua'
                                    ? 'Semua'
                                    : p == 'tinggi'
                                        ? 'Tinggi'
                                        : p == 'sedang'
                                            ? 'Sedang'
                                            : 'Rendah',
                                isSelected: _filterPrioritas == p,
                                onTap: () =>
                                    setState(() => _filterPrioritas = p),
                                cs: cs,
                              ),
                            ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.inbox_outlined,
                                      size: 56,
                                      color: cs.onSurface.withOpacity(0.2)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tidak ada tugas aktif',
                                    style: TextStyle(
                                      color: cs.onSurface.withOpacity(0.4),
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 4, 16, 120),
                              children: [
                                if (hariIni.isNotEmpty) ...[
                                  _SectionLabel(label: 'Hari Ini'),
                                  const SizedBox(height: 10),
                                  ...hariIni.map(
                                    (task) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: _TaskListCard(
                                        task: task,
                                        warnaMatKul: Color(
                                            mkProv.getWarna(task.mataKuliah)),
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                TaskDetailScreen(task: task),
                                          ),
                                        ),
                                        onSelesai: () =>
                                            taskProv.tandaiSelesai(task),
                                        onHapus: () => _hapusDenganUndo(
                                            context, taskProv, task),
                                      ),
                                    ),
                                  ),
                                ],
                                if (mendatang.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  _SectionLabel(label: 'Mendatang'),
                                  const SizedBox(height: 10),
                                  ...mendatang.map(
                                    (task) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: _TaskListCard(
                                        task: task,
                                        warnaMatKul: Color(
                                            mkProv.getWarna(task.mataKuliah)),
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                TaskDetailScreen(task: task),
                                          ),
                                        ),
                                        onSelesai: () =>
                                            taskProv.tandaiSelesai(task),
                                        onHapus: () => _hapusDenganUndo(
                                            context, taskProv, task),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ],
                ),

                // ── Tab Selesai ───────────────────────────────────
                const CompletedScreen(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _hapusDenganUndo(
      BuildContext ctx, TaskProvider provider, Task task) async {
    await provider.hapusTugas(task);
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('Tugas "${task.namaTugas}" dihapus'),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Batalkan',
          onPressed: provider.batalkanHapusTerakhir,
        ),
      ),
    );
  }
}

// ── Section Label ──────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      label,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: isDark ? const Color(0xFFEDE9FE) : const Color(0xFF1E1040),
      ),
    );
  }
}

// ── Filter Chip ────────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme cs;
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary
              : isDark
                  ? const Color(0xFF1C1826)
                  : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : cs.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ── Tab Badge ──────────────────────────────────────────────────────────────────
class _TabBadge extends StatelessWidget {
  final int count;
  final Color color;
  const _TabBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }
}

// ── Task List Card ─────────────────────────────────────────────────────────────
class _TaskListCard extends StatelessWidget {
  final Task task;
  final Color warnaMatKul;
  final VoidCallback onTap;
  final VoidCallback onSelesai;
  final VoidCallback onHapus;
  const _TaskListCard({
    required this.task,
    required this.warnaMatKul,
    required this.onTap,
    required this.onSelesai,
    required this.onHapus,
  });

  String get _sisaLabel {
    final sisa = task.sisaHari;
    if (sisa < 0) return 'Terlambat ${sisa.abs()}h';
    if (sisa == 0) return 'Hari ini!';
    if (sisa == 1) return 'Besok, ${_padded(task.deadline)}';
    return '$sisa Hari lagi';
  }

  String _padded(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String get _statusLabel {
    switch (task.status) {
      case 'proses':
        return 'DALAM PROSES';
      case 'selesai':
        return 'SELESAI';
      default:
        return 'BELUM MULAI';
    }
  }

  Color get _statusColor {
    switch (task.status) {
      case 'proses':
        return const Color(0xFF0EA5E9);
      case 'selesai':
        return const Color(0xFF059669);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  String get _prioritasLabel {
    switch (task.prioritas) {
      case 'tinggi':
        return 'TINGGI';
      case 'sedang':
        return 'SEDANG';
      default:
        return 'RENDAH';
    }
  }

  Color get _prioritasColor {
    switch (task.prioritas) {
      case 'tinggi':
        return const Color(0xFFDC2626);
      case 'sedang':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF059669);
    }
  }

  Color get _deadlineColor {
    final sisa = task.sisaHari;
    if (sisa < 0 || sisa == 0) return const Color(0xFFDC2626);
    if (sisa <= 2) return const Color(0xFFEA580C);
    return const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key('task_${task.id}'),
      background: _slideAction(const Color(0xFF059669), Icons.check_rounded,
          Alignment.centerLeft, 'Selesai'),
      secondaryBackground: _slideAction(const Color(0xFFDC2626),
          Icons.delete_rounded, Alignment.centerRight, 'Hapus'),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          onSelesai();
          return false;
        }
        return await _konfirmasiHapus(context);
      },
      onDismissed: (dir) {
        if (dir == DismissDirection.endToStart) onHapus();
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1826) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: warnaMatKul,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + priority
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.namaTugas,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isDark
                                    ? const Color(0xFFEDE9FE)
                                    : const Color(0xFF1E1040),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Priority dot + label
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _prioritasColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _prioritasLabel,
                                style: TextStyle(
                                  color: _prioritasColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Mata kuliah with dot
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
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

                      // Status pill + deadline
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _statusColor.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _statusLabel,
                              style: TextStyle(
                                color: _statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            task.sisaHari <= 0
                                ? Icons.error_outline_rounded
                                : Icons.calendar_today_outlined,
                            size: 12,
                            color: _deadlineColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _sisaLabel,
                            style: TextStyle(
                              color: _deadlineColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slideAction(
      Color color, IconData icon, Alignment alignment, String label) {
    return Container(
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Tugas?'),
        content: Text('Yakin ingin menghapus "${task.namaTugas}"?'),
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
