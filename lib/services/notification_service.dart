import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../models/task_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    try {
      await _initTimezone();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initSettings =
          InitializationSettings(android: androidSettings);

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {},
      );

      // Non-blocking permission request
      _requestPermissionSilently();

      _initialized = true;
    } catch (e) {
      _initialized = false;
      if (kDebugMode) debugPrint('NotificationService init error: $e');
    }
  }

  Future<void> _initTimezone() async {
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.UTC);
      } catch (_) {}
    }
  }

  void _requestPermissionSilently() {
    Future(() async {
      try {
        await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      } catch (_) {}
    });
  }

  Future<void> jadwalkanNotifikasiTugas(Task task) async {
    if (!_initialized || task.isSelesai) return;
    try {
      final now = DateTime.now();
      final d = task.deadline;
      final nama = task.namaTugas;

      // ── H-2: 2 hari sebelum deadline, jam 08:00 ──────────────────
      final h2 = DateTime(d.year, d.month, d.day - 2, 8, 0);
      if (h2.isAfter(now)) {
        await _jadwalkan(
          id: task.id * 10 + 1,
          judul: 'Deadline Tugas - 2 Hari Lagi',
          pesan: '$nama - 2 hari lagi! Jangan sampai telat.',
          waktu: h2,
        );
      }

      // ── H-1: 1 hari sebelum deadline, jam 08:00 ──────────────────
      final h1 = DateTime(d.year, d.month, d.day - 1, 8, 0);
      if (h1.isAfter(now)) {
        await _jadwalkan(
          id: task.id * 10 + 2,
          judul: 'Deadline Tugas - Besok!',
          pesan: '$nama - Besok deadline! Segera kerjakan.',
          waktu: h1,
        );
      }

      // ── H-0: hari deadline, jam 07:00 ────────────────────────────
      final h0 = DateTime(d.year, d.month, d.day, 7, 0);
      if (h0.isAfter(now)) {
        await _jadwalkan(
          id: task.id * 10 + 3,
          judul: 'DEADLINE HARI INI!',
          pesan: '$nama - HARI INI deadline! Kumpulkan sekarang.',
          waktu: h0,
        );
      }

      // ── 2 jam sebelum deadline ────────────────────────────────────
      // Selalu dijadwalkan kalau belum lewat, berguna untuk tugas mepet
      final minus2jam = d.subtract(const Duration(hours: 2));
      if (minus2jam.isAfter(now)) {
        await _jadwalkan(
          id: task.id * 10 + 4,
          judul: '⏰ 2 Jam Lagi Deadline!',
          pesan: '$nama - Tinggal 2 jam! Buruan kumpulkan.',
          waktu: minus2jam,
        );
      }

      // ── 30 menit sebelum deadline ─────────────────────────────────
      // Pengingat terakhir, sangat berguna kalau baru tambah tugas mepet
      final minus30menit = d.subtract(const Duration(minutes: 30));
      if (minus30menit.isAfter(now)) {
        await _jadwalkan(
          id: task.id * 10 + 5,
          judul: '🚨 30 Menit Lagi Deadline!',
          pesan: '$nama - 30 MENIT LAGI! Kumpulkan sekarang juga!',
          waktu: minus30menit,
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Gagal menjadwalkan notifikasi: $e');
    }
  }

  Future<void> batalkanNotifikasiTugas(int taskId) async {
    if (!_initialized) return;
    try {
      await Future.wait([
        _plugin.cancel(taskId * 10 + 1),
        _plugin.cancel(taskId * 10 + 2),
        _plugin.cancel(taskId * 10 + 3),
        _plugin.cancel(taskId * 10 + 4), // ← batalkan notif 2 jam
        _plugin.cancel(taskId * 10 + 5), // ← batalkan notif 30 menit
      ]);
    } catch (e) {
      if (kDebugMode) debugPrint('Gagal membatalkan notifikasi: $e');
    }
  }

  Future<void> _jadwalkan({
    required int id,
    required String judul,
    required String pesan,
    required DateTime waktu,
  }) async {
    try {
      final tzWaktu = tz.TZDateTime.from(waktu, tz.local);
      await _plugin.zonedSchedule(
        id,
        judul,
        pesan,
        tzWaktu,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'deadline_channel',
            'Deadline Tugas',
            channelDescription: 'Notifikasi pengingat deadline tugas kuliah',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('_jadwalkan error (id=$id): $e');
    }
  }
}
