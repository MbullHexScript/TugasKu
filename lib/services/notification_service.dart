import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../models/task_model.dart';
import 'hive_service.dart';

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

  /// Hitung jadwal notifikasi berdasarkan task (mode default atau custom)
  List<Map<String, dynamic>> _hitungJadwal(Task task) {
    final now = DateTime.now();
    final d = task.deadline;
    final nama = task.namaTugas;
    final jadwal = <Map<String, dynamic>>[];

    // ── H-2: selalu default, pukul 08.00 ─────────────────────────────────────
    final h2 = DateTime(d.year, d.month, d.day - 2, 8, 0);
    if (h2.isAfter(now)) {
      jadwal.add({
        'id': task.id * 10 + 1,
        'judul': 'Deadline Tugas — 2 Hari Lagi',
        'pesan': '$nama — 2 hari lagi! Jangan sampai telat.',
        'waktu': h2,
      });
    }

    // ── H (hari deadline): default atau custom ────────────────────────────────
    DateTime notifH;
    if (task.useCustomNotif && task.customNotifHour != null) {
      // Mode custom: jam yang dipilih user di hari deadline
      notifH = DateTime(
        d.year,
        d.month,
        d.day,
        task.customNotifHour!,
        task.customNotifMinute ?? 0,
      );
    } else {
      // Mode default: 2 jam sebelum deadline
      notifH = d.subtract(const Duration(hours: 2));
      // Fallback: jika hasil pengurangan bukan di hari yang sama
      if (notifH.day != d.day ||
          notifH.month != d.month ||
          notifH.year != d.year) {
        notifH = DateTime(d.year, d.month, d.day, 0, 1);
      }
    }

    if (notifH.isAfter(now)) {
      jadwal.add({
        'id': task.id * 10 + 3,
        'judul': 'DEADLINE HARI INI!',
        'pesan': '$nama — HARI INI deadline! Kumpulkan sekarang.',
        'waktu': notifH,
      });
    }

    return jadwal;
  }

  Future<void> jadwalkanNotifikasiTugas(Task task) async {
    if (!_initialized || task.isSelesai) return;
    try {
      final jadwal = _hitungJadwal(task);
      for (final item in jadwal) {
        await _jadwalkan(
          id: item['id'] as int,
          judul: item['judul'] as String,
          pesan: item['pesan'] as String,
          waktu: item['waktu'] as DateTime,
        );
        // Simpan log notifikasi
        await HiveService.simpanLogNotifikasi(
          judul: item['judul'] as String,
          pesan: item['pesan'] as String,
          waktu: item['waktu'] as DateTime,
          taskId: task.id,
          namaTugas: task.namaTugas,
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
        _plugin.cancel(taskId * 10 + 1), // H-2
        _plugin.cancel(taskId * 10 + 3), // H (default atau custom)
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
