import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final NotificationService _notifService;
  List<Task> _semuaTugas = [];

  String _filterPrioritas = 'semua';
  String _filterMataKuliah = 'semua';
  bool _filterMendekatiDeadline = false;
  String _searchQuery = '';

  // Untuk fitur undo delete
  Map<String, dynamic>? _lastDeletedData;

  TaskProvider(this._notifService) {
    _muatTugas();
  }

  Future<void> _safeNotif(Future<void> Function() action) async {
    try {
      await action().timeout(const Duration(seconds: 3));
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Notification error: $e');
        debugPrintStack(stackTrace: st);
      }
    }
  }

  // ── Getter ──
  List<Task> get semuaTugas => _semuaTugas;
  String get searchQuery => _searchQuery;

  List<Task> get tugasAktif {
    List<Task> hasil = _semuaTugas.where((t) => !t.isSelesai).toList();

    if (_filterPrioritas != 'semua') {
      hasil = hasil.where((t) => t.prioritas == _filterPrioritas).toList();
    }
    if (_filterMataKuliah != 'semua') {
      hasil = hasil.where((t) => t.mataKuliah == _filterMataKuliah).toList();
    }
    if (_filterMendekatiDeadline) {
      hasil = hasil.where((t) => t.isMendekatiDeadline).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      hasil = hasil
          .where((t) =>
              t.namaTugas.toLowerCase().contains(q) ||
              t.mataKuliah.toLowerCase().contains(q))
          .toList();
    }

    hasil.sort((a, b) => a.deadline.compareTo(b.deadline));
    return hasil;
  }

  List<Task> get tugasSelesai => _semuaTugas.where((t) => t.isSelesai).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Task> get tugasHariIni {
    final now = DateTime.now();
    final list = _semuaTugas.where((t) {
      if (t.isSelesai) return false;
      return t.deadline.year == now.year &&
          t.deadline.month == now.month &&
          t.deadline.day == now.day;
    }).toList();
    list.sort((a, b) => a.deadline.compareTo(b.deadline));
    return list;
  }

  List<Task> get tugasSegera => _semuaTugas
      .where((t) => !t.isSelesai && t.sisaHari <= 2 && t.sisaHari >= 0)
      .toList()
    ..sort((a, b) => a.deadline.compareTo(b.deadline));

  /// Semua tugas aktif tanpa filter (untuk kalender & statistik)
  List<Task> get semuaTugasAktif =>
      _semuaTugas.where((t) => !t.isSelesai).toList();

  String get filterPrioritas => _filterPrioritas;
  String get filterMataKuliah => _filterMataKuliah;
  bool get filterMendekatiDeadline => _filterMendekatiDeadline;

  int get jumlahAktif => _semuaTugas.where((t) => !t.isSelesai).length;
  int get jumlahSelesai => _semuaTugas.where((t) => t.isSelesai).length;
  int get jumlahMendekatiDeadline =>
      _semuaTugas.where((t) => t.isMendekatiDeadline).length;
  int get jumlahTerlambat => _semuaTugas.where((t) => t.isTerlambat).length;

  double get progressPenyelesaian {
    if (_semuaTugas.isEmpty) return 0.0;
    return jumlahSelesai / _semuaTugas.length;
  }

  /// Tugas per mata kuliah untuk statistik
  Map<String, int> get tugasPerMataKuliah {
    final map = <String, int>{};
    for (final t in _semuaTugas) {
      map[t.mataKuliah] = (map[t.mataKuliah] ?? 0) + 1;
    }
    return map;
  }

  /// Tugas yang deadline-nya jatuh pada tanggal tertentu
  List<Task> tugasUntukTanggal(DateTime tanggal) {
    final list = _semuaTugas.where((t) {
      return t.deadline.year == tanggal.year &&
          t.deadline.month == tanggal.month &&
          t.deadline.day == tanggal.day;
    }).toList();
    list.sort((a, b) => a.deadline.compareTo(b.deadline));
    return list;
  }

  bool get bisaBatalkanHapus => _lastDeletedData != null;

  // ── CRUD ──
  void _muatTugas() {
    _semuaTugas = HiveService.getTaskBox().values.toList();
    notifyListeners();
  }

  void reload() => _muatTugas();

  Future<void> tambahTugas(Task task) async {
    final box = HiveService.getTaskBox();
    final id = await HiveService.allocateTaskId();
    task.id = id;
    await box.put(id, task);
    await _safeNotif(() => _notifService.jadwalkanNotifikasiTugas(task));
    _muatTugas();
  }

  Future<void> editTugas(Task task) async {
    await _safeNotif(() => _notifService.batalkanNotifikasiTugas(task.id));
    await task.save();
    if (!task.isSelesai) {
      await _safeNotif(() => _notifService.jadwalkanNotifikasiTugas(task));
    }
    _muatTugas();
  }

  Future<void> hapusTugas(Task task) async {
    // Simpan data untuk undo
    _lastDeletedData = {
      'id': task.id,
      'namaTugas': task.namaTugas,
      'mataKuliah': task.mataKuliah,
      'prioritas': task.prioritas,
      'deadline': task.deadline,
      'isSelesai': task.isSelesai,
      'status': task.status,
      'createdAt': task.createdAt,
      'catatan': task.catatan,
      'subtasks': List<String>.from(task.subtasks),
      'subtasksDone': List<bool>.from(task.subtasksDone),
    };
    await _safeNotif(() => _notifService.batalkanNotifikasiTugas(task.id));
    await task.delete();
    _muatTugas();
  }

  /// Kembalikan tugas yang baru saja dihapus
  Future<void> batalkanHapusTerakhir() async {
    if (_lastDeletedData == null) return;
    final data = _lastDeletedData!;
    _lastDeletedData = null;
    final task = Task(
      id: data['id'] as int,
      namaTugas: data['namaTugas'] as String,
      mataKuliah: data['mataKuliah'] as String,
      prioritas: data['prioritas'] as String,
      deadline: data['deadline'] as DateTime,
      isSelesai: data['isSelesai'] as bool,
      status: data['status'] as String,
      createdAt: data['createdAt'] as DateTime,
      catatan: data['catatan'] as String,
      subtasks: data['subtasks'] as List<String>,
      subtasksDone: data['subtasksDone'] as List<bool>,
    );
    await HiveService.getTaskBox().put(task.id, task);
    if (!task.isSelesai) {
      await _safeNotif(() => _notifService.jadwalkanNotifikasiTugas(task));
    }
    _muatTugas();
  }

  Future<void> tandaiSelesai(Task task) async {
    task.isSelesai = true;
    task.status = 'selesai';
    await _safeNotif(() => _notifService.batalkanNotifikasiTugas(task.id));
    await task.save();
    _muatTugas();
  }

  Future<void> batalkanSelesai(Task task) async {
    task.isSelesai = false;
    task.status = 'belum';
    await task.save();
    await _safeNotif(() => _notifService.jadwalkanNotifikasiTugas(task));
    _muatTugas();
  }

  Future<void> toggleSubtask(Task task, int index) async {
    if (index >= task.subtasksDone.length) return;
    task.subtasksDone[index] = !task.subtasksDone[index];
    await task.save();
    _muatTugas();
  }

  // ── Filter & Search ──
  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setFilterPrioritas(String nilai) {
    _filterPrioritas = nilai;
    notifyListeners();
  }

  void setFilterMataKuliah(String nilai) {
    _filterMataKuliah = nilai;
    notifyListeners();
  }

  void toggleFilterMendekatiDeadline() {
    _filterMendekatiDeadline = !_filterMendekatiDeadline;
    notifyListeners();
  }

  void resetFilter() {
    _filterPrioritas = 'semua';
    _filterMataKuliah = 'semua';
    _filterMendekatiDeadline = false;
    _searchQuery = '';
    notifyListeners();
  }
}
