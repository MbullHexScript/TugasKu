import 'package:hive/hive.dart';
part 'notification_log_model.g.dart';

@HiveType(typeId: 2)
class NotificationLog extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String judul;

  @HiveField(2)
  String pesan;

  /// Waktu notifikasi dijadwalkan dikirim
  @HiveField(3)
  DateTime waktu;

  @HiveField(4)
  bool sudahDibaca;

  /// Referensi ke Task (nullable)
  @HiveField(5)
  int? taskId;

  /// Snapshot nama tugas saat log dibuat
  @HiveField(6)
  String? namaTugas;

  NotificationLog({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.waktu,
    this.sudahDibaca = false,
    this.taskId,
    this.namaTugas,
  });
}
