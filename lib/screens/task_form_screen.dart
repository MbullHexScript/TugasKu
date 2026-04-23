import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/mata_kuliah_provider.dart';

/// Screen untuk tambah / edit tugas
class TaskFormScreen extends StatefulWidget {
  final Task? task; // null = mode tambah, ada isi = mode edit

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaTugasCtrl;
  late String _mataKuliah;
  late String _prioritas;
  late DateTime _deadline;
  late String _status;
  bool _isSaving = false;

  bool get isEditMode => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _namaTugasCtrl = TextEditingController(text: task?.namaTugas ?? '');
    _mataKuliah = task?.mataKuliah ?? '';
    _prioritas = task?.prioritas ?? 'sedang';
    _deadline = task?.deadline ?? DateTime.now().add(const Duration(days: 7));
    _status = task?.status ?? 'belum';
  }

  @override
  void dispose() {
    _namaTugasCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline),
    );
    if (time == null) return;

    setState(() {
      _deadline = DateTime(
          picked.year, picked.month, picked.day, time.hour, time.minute);
    });
  }

  Future<void> _simpan() async {
    if (_isSaving) return;

    final form = _formKey.currentState;
    if (form == null) return;

    FocusScope.of(context).unfocus();

    if (!form.validate()) return;
    if (_mataKuliah.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih mata kuliah terlebih dahulu')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final provider = context.read<TaskProvider>();
      if (isEditMode) {
        final task = widget.task!;
        task.namaTugas = _namaTugasCtrl.text.trim();
        task.mataKuliah = _mataKuliah;
        task.prioritas = _prioritas;
        task.deadline = _deadline;
        task.status = _status;
        task.isSelesai = _status == 'selesai';
        await provider.editTugas(task);
      } else {
        final task = Task(
          id: 0,
          namaTugas: _namaTugasCtrl.text.trim(),
          mataKuliah: _mataKuliah,
          prioritas: _prioritas,
          deadline: _deadline,
          isSelesai: _status == 'selesai',
          status: _status,
          createdAt: DateTime.now(),
        );
        await provider.tambahTugas(task);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan tugas: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatDeadline(DateTime dt) {
    const bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final mkProvider = context.watch<MataKuliahProvider>();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_mataKuliah.isEmpty && mkProvider.namaMataKuliah.isNotEmpty) {
      _mataKuliah = mkProvider.namaMataKuliah.first;
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0D13) : const Color(0xFFF4F3FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: cs.primary),
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
        ),
        title: Text(
          isEditMode ? 'Edit Tugas' : 'Tambah Tugas',
          style: TextStyle(
            color: cs.primary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          Icon(Icons.notifications_outlined, color: cs.primary),
          const SizedBox(width: 16),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
          children: [
            // ── Page heading ───────────────────────────────────────
            Text(
              'FOKUS AKADEMIK',
              style: TextStyle(
                color: cs.onSurface.withOpacity(0.45),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isEditMode ? 'Edit\nTugas Ini.' : 'Detail\nTugas Baru.',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color:
                    isDark ? const Color(0xFFEDE9FE) : const Color(0xFF1E1040),
                height: 1.2,
              ),
            ),

            const SizedBox(height: 28),

            // ── Nama Tugas ─────────────────────────────────────────
            _FieldLabel('Nama Tugas *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _namaTugasCtrl,
              decoration: InputDecoration(
                hintText: 'Masukkan nama tugas...',
                hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.35)),
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF1C1826) : const Color(0xFFEEEBFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              ),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Nama tugas wajib diisi'
                  : null,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 20),

            // ── Mata Kuliah ─────────────────────────────────────────
            _FieldLabel('Mata Kuliah *'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _mataKuliah.isNotEmpty ? _mataKuliah : null,
              decoration: InputDecoration(
                hintText: 'Pilih mata kuliah',
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF1C1826) : const Color(0xFFEEEBFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              ),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: cs.primary),
              items: mkProvider.namaMataKuliah
                  .map((nama) =>
                      DropdownMenuItem(value: nama, child: Text(nama)))
                  .toList(),
              onChanged: (val) => setState(() => _mataKuliah = val ?? ''),
              validator: (val) =>
                  (val == null || val.isEmpty) ? 'Pilih mata kuliah' : null,
            ),

            const SizedBox(height: 20),

            // ── Prioritas ──────────────────────────────────────────
            Container(
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
                  Text(
                    'Prioritas',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark
                          ? const Color(0xFFEDE9FE)
                          : const Color(0xFF1E1040),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final p in ['rendah', 'sedang', 'tinggi'])
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () => setState(() => _prioritas = p),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _prioritas == p
                                      ? cs.primary
                                      : isDark
                                          ? const Color(0xFF2D2640)
                                          : const Color(0xFFF0EEFF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    p[0].toUpperCase() + p.substring(1),
                                    style: TextStyle(
                                      color: _prioritas == p
                                          ? Colors.white
                                          : cs.onSurface.withOpacity(0.6),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Deadline ──────────────────────────────────────────
            Container(
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
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.calendar_month_rounded,
                        color: cs.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DEADLINE',
                          style: TextStyle(
                            color: cs.onSurface.withOpacity(0.45),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _formatDeadline(_deadline),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isDark
                                ? const Color(0xFFEDE9FE)
                                : const Color(0xFF1E1040),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _pilihDeadline,
                    child: Text('Ubah',
                        style: TextStyle(
                            color: cs.primary, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Status ────────────────────────────────────────────
            _FieldLabel('Status'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF1C1826) : const Color(0xFFEEEBFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              ),
              icon: Icon(Icons.unfold_more_rounded,
                  color: cs.onSurface.withOpacity(0.5)),
              items: const [
                DropdownMenuItem(value: 'belum', child: Text('Belum')),
                DropdownMenuItem(
                    value: 'proses', child: Text('Sedang Dikerjakan')),
                DropdownMenuItem(value: 'selesai', child: Text('Selesai')),
              ],
              onChanged: (val) => setState(() => _status = val ?? 'belum'),
            ),

            const SizedBox(height: 32),

            // ── Action Buttons ────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isSaving ? null : () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(
                          color: cs.onSurface.withOpacity(0.25), width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _simpan,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save_rounded,
                            color: Colors.white, size: 20),
                    label: Text(
                      _isSaving
                          ? 'Menyimpan...'
                          : (isEditMode ? 'Simpan' : 'Tambah Tugas'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: isDark ? const Color(0xFFEDE9FE) : const Color(0xFF1E1040),
      ),
    );
  }
}
