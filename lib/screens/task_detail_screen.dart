import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/mata_kuliah_provider.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _catatanCtrl;
  late TextEditingController _subtaskCtrl;
  bool _editingCatatan = false;

  @override
  void initState() {
    super.initState();
    _catatanCtrl = TextEditingController(text: widget.task.catatan);
    _subtaskCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _catatanCtrl.dispose();
    _subtaskCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveCatatan() async {
    widget.task.catatan = _catatanCtrl.text;
    await context.read<TaskProvider>().editTugas(widget.task);
    if (mounted) setState(() => _editingCatatan = false);
  }

  Future<void> _tambahSubtask(TaskProvider provider) async {
    final nama = _subtaskCtrl.text.trim();
    if (nama.isEmpty) return;
    widget.task.subtasks.add(nama);
    widget.task.subtasksDone.add(false);
    await provider.editTugas(widget.task);
    _subtaskCtrl.clear();
    if (mounted) setState(() {});
  }

  Future<void> _hapusSubtask(TaskProvider provider, int index) async {
    widget.task.subtasks.removeAt(index);
    widget.task.subtasksDone.removeAt(index);
    await provider.editTugas(widget.task);
    if (mounted) setState(() {});
  }

  void _share() {
    final t = widget.task;
    final dl = '${t.deadline.day}/${t.deadline.month}/${t.deadline.year}';
    final subs = t.subtasks.isEmpty
        ? ''
        : '\n\nSubtask:\n${List.generate(t.subtasks.length, (i) => '${t.subtasksDone[i] ? '✅' : '⬜'} ${t.subtasks[i]}').join('\n')}';
    final text =
        '📚 ${t.namaTugas}\nMata Kuliah: ${t.mataKuliah}\nPrioritas: ${t.prioritas}\nDeadline: $dl\nStatus: ${t.status}$subs';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Detail tugas disalin ke clipboard!'),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatDeadline(DateTime dt) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String get _sisaHariLabel {
    final sisa = widget.task.sisaHari;
    if (sisa < 0) return 'Terlambat ${sisa.abs()} Hari';
    if (sisa == 0) return 'Hari Ini!';
    if (sisa == 1) return '1 Hari Lagi';
    return '$sisa Hari Lagi';
  }

  String get _prioritasLabel {
    switch (widget.task.prioritas) {
      case 'tinggi':
        return 'PENTING';
      case 'sedang':
        return 'SEDANG';
      default:
        return 'RENDAH';
    }
  }

  Color get _prioritasColor {
    switch (widget.task.prioritas) {
      case 'tinggi':
        return const Color(0xFFDC2626);
      case 'sedang':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF059669);
    }
  }

  String get _statusLabel {
    switch (widget.task.status) {
      case 'proses':
        return 'Sedang Dikerjakan';
      case 'selesai':
        return 'Selesai';
      default:
        return 'Belum Dimulai';
    }
  }

  Color get _statusDotColor {
    switch (widget.task.status) {
      case 'proses':
        return const Color(0xFF0EA5E9);
      case 'selesai':
        return const Color(0xFF059669);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<TaskProvider>();
    context.watch<MataKuliahProvider>(); // ensure rebuild on changes
    final task = widget.task;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = (task.progressSubtask * 100).round();

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0D13) : const Color(0xFFF4F3FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: cs.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Tugas',
          style: TextStyle(
            color: cs.primary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: cs.primary, size: 22),
            tooltip: 'Salin ke clipboard',
            onPressed: _share,
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: cs.primary, size: 22),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => TaskFormScreen(task: task)),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
        children: [
          // ── Hero Header Card ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chip row: mata kuliah + prioritas + sisa hari
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    // Mata kuliah chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        task.mataKuliah.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    // Prioritas chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _prioritasColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _prioritasLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    // Sisa hari chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded,
                              color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            _sisaHariLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Task name
                Text(
                  task.namaTugas,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 14),

                // Deadline
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Deadline: ${_formatDeadline(task.deadline)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Status Sekarang ───────────────────────────────────────
          _DetailCard(
            label: 'STATUS SEKARANG',
            trailing: GestureDetector(
              onTap: () => _showStatusDialog(provider),
              child: Text(
                'Ubah',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _statusDotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _statusLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isDark
                        ? const Color(0xFFEDE9FE)
                        : const Color(0xFF1E1040),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Progress Subtask ──────────────────────────────────────
          if (task.subtasks.isNotEmpty) ...[
            _DetailCard(
              label: 'PROGRESS SUBTASK',
              trailing: Text(
                '$pct%',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: task.progressSubtask,
                  minHeight: 8,
                  backgroundColor: cs.primary.withOpacity(0.12),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(cs.primary),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // ── Daftar Subtask ────────────────────────────────────────
          _DetailCard(
            label: 'DAFTAR SUBTASK',
            trailing: GestureDetector(
              onTap: () => _showAddSubtaskDialog(provider),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: cs.primary, size: 14),
                  const SizedBox(width: 2),
                  Text(
                    'TAMBAH',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            child: task.subtasks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Belum ada subtask. Tap + TAMBAH untuk memecah tugas.',
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.4),
                        fontSize: 13,
                      ),
                    ),
                  )
                : Column(
                    children: List.generate(task.subtasks.length, (i) {
                      final done = i < task.subtasksDone.length
                          ? task.subtasksDone[i]
                          : false;
                      return GestureDetector(
                        onLongPress: () =>
                            _hapusSubtask(provider, i),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    provider.toggleSubtask(task, i),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: done
                                        ? cs.primary
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: done
                                          ? cs.primary
                                          : cs.onSurface
                                              .withOpacity(0.3),
                                      width: 1.8,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: done
                                      ? const Icon(Icons.check_rounded,
                                          color: Colors.white, size: 14)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  task.subtasks[i],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: done
                                        ? cs.onSurface.withOpacity(0.4)
                                        : isDark
                                            ? const Color(0xFFEDE9FE)
                                            : const Color(0xFF1E1040),
                                    decoration: done
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor:
                                        cs.onSurface.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
          ),

          const SizedBox(height: 10),

          // ── Catatan Tambahan ──────────────────────────────────────
          _DetailCard(
            label: 'CATATAN TAMBAHAN',
            child: _editingCatatan
                ? Column(
                    children: [
                      TextField(
                        controller: _catatanCtrl,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText:
                              'Tambahkan detail atau instruksi dosen di sini...',
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF2D2640)
                              : const Color(0xFFF0EEFF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _saveCatatan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: const Text('Simpan',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: () =>
                        setState(() => _editingCatatan = true),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2D2640)
                            : const Color(0xFFF0EEFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.catatan.isEmpty
                            ? 'Tambahkan detail atau instruksi dosen di sini...'
                            : task.catatan,
                        style: TextStyle(
                          color: task.catatan.isEmpty
                              ? cs.onSurface.withOpacity(0.35)
                              : isDark
                                  ? const Color(0xFFEDE9FE)
                                  : const Color(0xFF1E1040),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 24),
        ],
      ),

      // ── Bottom Action Button ──────────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        color: isDark
            ? const Color(0xFF0F0D13)
            : const Color(0xFFF4F3FF),
        child: task.isSelesai
            ? OutlinedButton.icon(
                onPressed: () async {
                  await provider.batalkanSelesai(task);
                  if (mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Batalkan Selesai',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              )
            : ElevatedButton.icon(
                onPressed: () async {
                  await provider.tandaiSelesai(task);
                  if (mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle_rounded,
                    color: Colors.white),
                label: const Text(
                  'Tandai Selesai',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
      ),
    );
  }

  // ── Show Status Dialog ────────────────────────────────────────────
  void _showStatusDialog(TaskProvider provider) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1C1826)
              : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ubah Status',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              for (final entry in {
                'belum': 'Belum Dimulai',
                'proses': 'Sedang Dikerjakan',
                'selesai': 'Selesai',
              }.entries)
                ListTile(
                  onTap: () async {
                    widget.task.status = entry.key;
                    widget.task.isSelesai = entry.key == 'selesai';
                    await provider.editTugas(widget.task);
                    if (mounted) {
                      Navigator.pop(context);
                      setState(() {});
                    }
                  },
                  leading: CircleAvatar(
                    radius: 5,
                    backgroundColor: entry.key == 'selesai'
                        ? const Color(0xFF059669)
                        : entry.key == 'proses'
                            ? const Color(0xFF0EA5E9)
                            : const Color(0xFF9CA3AF),
                  ),
                  title: Text(entry.value,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: widget.task.status == entry.key
                      ? Icon(Icons.check_rounded, color: cs.primary)
                      : null,
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Show Add Subtask Dialog ────────────────────────────────────────
  void _showAddSubtaskDialog(TaskProvider provider) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1C1826)
              : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              20 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tambah Subtask',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _subtaskCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Nama subtask...',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                onSubmitted: (_) {
                  _tambahSubtask(provider);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _tambahSubtask(provider);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tambah',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Detail Card ────────────────────────────────────────────────────────────────
class _DetailCard extends StatelessWidget {
  final String label;
  final Widget child;
  final Widget? trailing;

  const _DetailCard(
      {required this.label, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1826) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: cs.onSurface.withOpacity(0.45),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
