import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/mata_kuliah_provider.dart';
import 'settings_screen.dart';

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

  // ── Fitur 1: Pengingat custom ──
  late bool _useDefaultNotif;
  late int _customNotifHour;
  late int _customNotifMinute;

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

    // Notif: default ON (useCustomNotif false → toggle default ON)
    _useDefaultNotif = !(task?.useCustomNotif ?? false);
    _customNotifHour = task?.customNotifHour ?? 20;
    _customNotifMinute = task?.customNotifMinute ?? 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_mataKuliah.isEmpty && !isEditMode) {
      final mkProvider = context.read<MataKuliahProvider>();
      if (mkProvider.namaMataKuliah.isNotEmpty) {
        _mataKuliah = mkProvider.namaMataKuliah.first;
      }
    }
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
    if (!mounted) return;

    final time = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline),
    );
    if (time == null) return;

    setState(() {
      _deadline = DateTime(
          picked.year, picked.month, picked.day, time.hour, time.minute);
    });
  }

  Future<void> _pilihWaktuNotif() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
          hour: _customNotifHour, minute: _customNotifMinute),
      helpText: 'Pilih jam pengingat di hari deadline',
    );
    if (picked == null) return;
    setState(() {
      _customNotifHour = picked.hour;
      _customNotifMinute = picked.minute;
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

    final provider = context.read<TaskProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    setState(() => _isSaving = true);
    try {
      final useCustom = !_useDefaultNotif;
      if (isEditMode) {
        final task = widget.task!;
        task.namaTugas = _namaTugasCtrl.text.trim();
        task.mataKuliah = _mataKuliah;
        task.prioritas = _prioritas;
        task.deadline = _deadline;
        task.status = _status;
        task.isSelesai = _status == 'selesai';
        task.useCustomNotif = useCustom;
        task.customNotifHour = useCustom ? _customNotifHour : null;
        task.customNotifMinute = useCustom ? _customNotifMinute : null;
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
          useCustomNotif: useCustom,
          customNotifHour: useCustom ? _customNotifHour : null,
          customNotifMinute: useCustom ? _customNotifMinute : null,
        );
        await provider.tambahTugas(task);
      }
      if (mounted) nav.pop(true);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal menyimpan tugas: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatDeadline(DateTime dt) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatJamMenit(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} WIB';
  }

  @override
  Widget build(BuildContext context) {
    final mkProvider = context.watch<MataKuliahProvider>();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Tampilkan pesan jika belum ada mata kuliah
    if (!isEditMode && mkProvider.namaMataKuliah.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: cs.primary),
            onPressed: () => Navigator.pop(context, false),
          ),
          title: Text(
            'Tambah Tugas',
            style: TextStyle(
              color: cs.primary,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.menu_book_rounded,
                      color: cs.primary, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  'Belum Ada Mata Kuliah',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tambahkan mata kuliah terlebih dahulu di halaman Pengaturan, lalu kembali untuk menambahkan tugas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurface.withOpacity(0.55),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, false);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()),
                    );
                  },
                  icon: const Icon(Icons.settings_rounded,
                      color: Colors.white, size: 18),
                  label: const Text(
                    'Buka Pengaturan',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_mataKuliah.isEmpty && mkProvider.namaMataKuliah.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _mataKuliah = mkProvider.namaMataKuliah.first);
        }
      });
    }

    // ── Build dropdown items dengan grouping ──
    final semesterIni = mkProvider.mataKuliahSemesterIni;
    final lintasSemester = mkProvider.mataKuliahLintasSemester;
    final semAktif = mkProvider.semesterAktif;

    final dropdownItems = <DropdownMenuItem<String>>[];

    // Header "Semester Ini"
    if (semesterIni.isNotEmpty) {
      dropdownItems.add(DropdownMenuItem<String>(
        enabled: false,
        value: '__header_ini__',
        child: Text(
          '── Semester Ini (Sem $semAktif) ──',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: cs.primary.withOpacity(0.6),
            letterSpacing: 0.3,
          ),
        ),
      ));
      for (final mk in semesterIni) {
        dropdownItems.add(DropdownMenuItem<String>(
          value: mk.nama,
          child: Text(mk.nama),
        ));
      }
    }

    // Header "Semester Lain"
    if (lintasSemester.isNotEmpty) {
      dropdownItems.add(DropdownMenuItem<String>(
        enabled: false,
        value: '__header_lain__',
        child: Text(
          '── Semester Lain ──',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: cs.onSurface.withOpacity(0.4),
            letterSpacing: 0.3,
          ),
        ),
      ));
      for (final mk in lintasSemester) {
        dropdownItems.add(DropdownMenuItem<String>(
          value: mk.nama,
          child: Text('${mk.nama} (Sem ${mk.semester})'),
        ));
      }
    }

    // Pastikan value yang dipilih valid (bukan header)
    final validValues = dropdownItems
        .where((item) => item.enabled != false)
        .map((item) => item.value!)
        .toList();
    final currentValue =
        validValues.contains(_mataKuliah) ? _mataKuliah : null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
          children: [
            // ── Page heading ──
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
                color: cs.onSurface,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 28),

            // ── Nama Tugas ──
            _FieldLabel('Nama Tugas *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _namaTugasCtrl,
              decoration: InputDecoration(
                hintText: 'Masukkan nama tugas...',
                hintStyle:
                    TextStyle(color: cs.onSurface.withOpacity(0.35)),
                filled: true,
                fillColor: isDark
                    ? cs.surfaceContainerHighest
                    : cs.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 16),
              ),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Nama tugas wajib diisi'
                  : null,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 20),

            // ── Mata Kuliah (Grouped Dropdown) ──
            _FieldLabel('Mata Kuliah *'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: currentValue,
              decoration: InputDecoration(
                hintText: 'Pilih mata kuliah',
                filled: true,
                fillColor: isDark
                    ? cs.surfaceContainerHighest
                    : cs.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 16),
              ),
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: cs.primary),
              items: dropdownItems,
              onChanged: (val) {
                if (val != null) setState(() => _mataKuliah = val);
              },
              validator: (val) =>
                  (val == null || val.isEmpty || val.startsWith('__'))
                      ? 'Pilih mata kuliah'
                      : null,
            ),

            const SizedBox(height: 20),

            // ── Prioritas ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? cs.surfaceContainerHighest
                    : cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      cs.outlineVariant.withOpacity(isDark ? 0.20 : 0.55),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prioritas',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final p in ['rendah', 'sedang', 'tinggi'])
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _prioritas = p),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10),
                                decoration: BoxDecoration(
                                  color: _prioritas == p
                                      ? cs.primary
                                      : isDark
                                          ? cs.surfaceContainerHigh
                                          : cs.surfaceContainerLow,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: Border.all(
                                    color: cs.outlineVariant.withOpacity(
                                        isDark ? 0.18 : 0.60),
                                  ),
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

            // ── Deadline ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? cs.surfaceContainerHighest
                    : cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      cs.outlineVariant.withOpacity(isDark ? 0.20 : 0.55),
                ),
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
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _pilihDeadline,
                    child: Text('Ubah',
                        style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Card Pengingat (Fitur 1) ──
            _buildPengingatCard(cs, isDark),

            const SizedBox(height: 20),

            // ── Status ──
            _FieldLabel('Status'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark
                    ? cs.surfaceContainerHighest
                    : cs.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 16),
              ),
              icon: Icon(Icons.unfold_more_rounded,
                  color: cs.onSurface.withOpacity(0.5)),
              items: const [
                DropdownMenuItem(value: 'belum', child: Text('Belum')),
                DropdownMenuItem(
                    value: 'proses',
                    child: Text('Sedang Dikerjakan')),
                DropdownMenuItem(
                    value: 'selesai', child: Text('Selesai')),
              ],
              onChanged: (val) =>
                  setState(() => _status = val ?? 'belum'),
            ),

            const SizedBox(height: 32),

            // ── Action Buttons ──
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(
                          color: cs.onSurface.withOpacity(0.25),
                          width: 1.5),
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
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
                      padding:
                          const EdgeInsets.symmetric(vertical: 15),
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

  /// Card Pengingat — Fitur 1
  Widget _buildPengingatCard(ColorScheme cs, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHighest
            : cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(isDark ? 0.20 : 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Icon(Icons.notifications_rounded, color: cs.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'PENGINGAT',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: cs.onSurface,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Toggle default
          Row(
            children: [
              Expanded(
                child: Text(
                  'Gunakan pengaturan default',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Switch(
                value: _useDefaultNotif,
                onChanged: (val) => setState(() => _useDefaultNotif = val),
                activeColor: cs.primary,
              ),
            ],
          ),

          // Info box atau picker — animasi smooth
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _useDefaultNotif
                ? _buildInfoDefault(cs, isDark)
                : _buildCustomPicker(cs, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDefault(ColorScheme cs, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              text: 'H-2: notif pukul 08.00 pagi',
              cs: cs,
            ),
            const SizedBox(height: 6),
            _InfoRow(
              icon: Icons.access_time_rounded,
              text: 'H : notif 2 jam sebelum deadline',
              cs: cs,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomPicker(ColorScheme cs, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kirim notif di hari deadline pada pukul:',
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurface.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Tampilan jam terpilih
              GestureDetector(
                onTap: _pilihWaktuNotif,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? cs.surfaceContainerHigh
                        : cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _formatJamMenit(_customNotifHour, _customNotifMinute),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: cs.primary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: _pilihWaktuNotif,
                child: Text(
                  'Pilih Waktu',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Info H-2 tetap
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 14, color: cs.onSurface.withOpacity(0.45)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Notif H-2 tetap dikirim pukul 08.00 pagi.',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: cs.onSurface,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final ColorScheme cs;
  const _InfoRow(
      {required this.icon, required this.text, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: cs.primary.withOpacity(0.7)),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: cs.primary.withOpacity(0.85),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
