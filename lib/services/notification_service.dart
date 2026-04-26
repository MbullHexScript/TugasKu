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
      tzdata.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      } catch (_) {
        // Fallback ke UTC jika Asia/Jakarta tidak tersedia
        tz.setLocalLocation(tz.UTC);
      }

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initSettings =
          InitializationSettings(android: androidSettings);

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          // Handle notification tap jika diperlukan
        },
      );

      // Minta izin notifikasi di Android 13+ (opsional, tidak crash jika gagal)
      try {
        await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      } catch (_) {
        // Abaikan error permission — notifikasi tetap bisa jalan di banyak device
      }

      _initialized = true;
    } catch (e) {
      _initialized = false;
      if (kDebugMode) {
        debugPrint('NotificationService init error: $e');
      }
    }
  }

  // Jadwalkan notifikasi H-2, H-1, H-0 untuk tugas
  Future<void> jadwalkanNotifikasiTugas(Task task) async {
    if (!_initialized || task.isSelesai) return;

    try {
      final now = DateTime.now();
      final d = task.deadline;
      final nama = task.namaTugas;

      // H-2: 2 hari sebelum deadline jam 08:00
      final h2 = DateTime(d.year, d.month, d.day - 2, 8, 0);
      if (h2.isAfter(now)) {
        await _jadwalkan(
          id: task.id * 10 + 1,
          judul: 'Deadline Tugas - 2 Hari Lagi',
          pesan: '$nama - 2 hari lagi! Jangan sampai telat.',
          waktu: h2,
        );
      }

      // H-1: 1 hari sebelum deadline jam 08:00
      final h1 = DateTime(d.year, d.month, d.day - 1, 8, 0);
      if (h1.isAfter(now)) {
        await _jadwalkan(
          id: task.id * 10 + 2,
          judul: 'Deadline Tugas - Besok!',
          pesan: '$nama - Besok deadline! Segera kerjakan.',
          waktu: h1,
        );
      }

      // H-0: hari deadline jam 07:00
      final h0 = DateTime(d.year, d.month, d.day, 7, 0);
      if (h0.isAfter(now)) {
        await _jadwalkan(
          id: task.id * 10 + 3,
          judul: 'DEADLINE HARI INI!',
          pesan: '$nama - HARI INI deadline! Kumpulkan sekarang.',
          waktu: h0,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Gagal menjadwalkan notifikasi: $e');
      }
    }
  }

  // Batalkan semua notifikasi satu tugas
  Future<void> batalkanNotifikasiTugas(int taskId) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(taskId * 10 + 1);
      await _plugin.cancel(taskId * 10 + 2);
      await _plugin.cancel(taskId * 10 + 3);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Gagal membatalkan notifikasi: $e');
      }
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
        // Parameter wajib untuk flutter_local_notifications versi 17.x
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('_jadwalkan error (id=$id): $e');
      }
    }
  }
}
