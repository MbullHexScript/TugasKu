import 'package:hive/hive.dart';
part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String namaTugas;

  @HiveField(2)
  String mataKuliah;

  /// 'tinggi' | 'sedang' | 'rendah'
  @HiveField(3)
  String prioritas;

  @HiveField(4)
  DateTime deadline;

  @HiveField(5)
  bool isSelesai;

  /// 'belum' | 'proses' | 'selesai'
  @HiveField(6)
  String status;

  @HiveField(7)
  DateTime createdAt;

  /// Catatan / notes bebas
  @HiveField(8)
  String catatan;

  /// Daftar nama sub-tugas
  @HiveField(9)
  List<String> subtasks;

  /// Status selesai per sub-tugas (index sesuai subtasks)
  @HiveField(10)
  List<bool> subtasksDone;

  Task({
    required this.id,
    required this.namaTugas,
    required this.mataKuliah,
    required this.prioritas,
    required this.deadline,
    this.isSelesai = false,
    this.status = 'belum',
    required this.createdAt,
    this.catatan = '',
    List<String>? subtasks,
    List<bool>? subtasksDone,
  })  : subtasks = subtasks ?? [],
        subtasksDone = subtasksDone ?? [];

  int get sisaHari {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dl = DateTime(deadline.year, deadline.month, deadline.day);
    return dl.difference(today).inDays;
  }

  bool get isTerlambat => sisaHari < 0 && !isSelesai;
  bool get isMendekatiDeadline => sisaHari <= 3 && sisaHari >= 0 && !isSelesai;

  int get jumlahSubtaskSelesai => subtasksDone.where((d) => d).length;
  double get progressSubtask =>
      subtasks.isEmpty ? 0.0 : jumlahSubtaskSelesai / subtasks.length;
}
