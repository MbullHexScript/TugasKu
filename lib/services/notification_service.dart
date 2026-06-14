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

  static const String _channelId   = 'deadline_channel_v3';
  static const String _channelName = 'Deadline Tugas';
  static const String _channelDesc = 'Notifikasi pengingat deadline tugas kuliah';

  // ────────────────────────────────────────────────────────────────────────────
  // INIT
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> init() async {
    try {
      await _initTimezone();

      // Gunakan @mipmap/ic_launcher sebagai default yang PASTI ada.
      // ic_stat_icon hanya dipakai saat show/schedule lewat _notifDetails.
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initSettings =
          InitializationSettings(android: androidSettings);

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          if (kDebugMode) debugPrint('Notifikasi di-tap: ${details.payload}');
        },
      );

      await _createNotificationChannel();
      await _requestPermissions();

      _initialized = true;
      if (kDebugMode) debugPrint('✅ NotificationService initialized');
    } catch (e, st) {
      _initialized = false;
      if (kDebugMode) {
        debugPrint('❌ NotificationService init error: $e');
        debugPrint(st.toString());
      }
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // CHANNEL
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> _createNotificationChannel() async {
    try {
      const sound = RawResourceAndroidNotificationSound('notif_sound');

      final channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
        sound: sound,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      if (kDebugMode) debugPrint('✅ Notification channel created: $_channelId');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ _createNotificationChannel error: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // TIMEZONE
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> _initTimezone() async {
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      if (kDebugMode) debugPrint('✅ Timezone: Asia/Jakarta');
    } catch (_) {
      try {
        tz.setLocalLocation(tz.UTC);
        if (kDebugMode) debugPrint('⚠️ Timezone fallback: UTC');
      } catch (_) {}
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // PERMISSIONS
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> _requestPermissions() async {
    try {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final notifGranted = await androidImpl?.requestNotificationsPermission();
      if (kDebugMode) debugPrint('Notif permission: $notifGranted');

      final alarmGranted = await androidImpl?.requestExactAlarmsPermission();
      if (kDebugMode) debugPrint('Exact alarm permission: $alarmGranted');
    } catch (e) {
      if (kDebugMode) debugPrint('Permission error: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // NOTIFICATION DETAILS
  // Gunakan ic_stat_icon jika ada, fallback ke ic_launcher.
  // Android hanya menampilkan area PUTIH dari icon — background transparan.
  // ────────────────────────────────────────────────────────────────────────────
  AndroidNotificationDetails _buildAndroidDetails({String? iconName}) {
    return AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      // Coba ic_stat_icon dulu; kalau file tidak ada akan fallback ke default app icon
      icon: iconName ?? 'ic_stat_icon',
      importance: Importance.high,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('notif_sound'),
      playSound: true,
      enableVibration: true,
      ticker: 'TugasKu — ada deadline!',
      styleInformation: const BigTextStyleInformation(''),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HITUNG JADWAL
  // ────────────────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _hitungJadwal(Task task) {
    final now  = DateTime.now();
    final d    = task.deadline;
    final nama = task.namaTugas;
    final jadwal = <Map<String, dynamic>>[];

    // H-2: jam 08.00
    final h2 = DateTime(d.year, d.month, d.day - 2, 8, 0);
    if (h2.isAfter(now)) {
      jadwal.add({
        'id'    : task.id * 10 + 1,
        'judul' : '📅 Deadline Tugas — 2 Hari Lagi',
        'pesan' : '$nama — 2 hari lagi! Jangan sampai telat.',
        'waktu' : h2,
      });
    }

    // H-1: jam 08.00
    final h1 = DateTime(d.year, d.month, d.day - 1, 8, 0);
    if (h1.isAfter(now)) {
      jadwal.add({
        'id'    : task.id * 10 + 2,
        'judul' : '⚠️ Deadline Tugas — Besok!',
        'pesan' : '$nama — besok deadline! Segera selesaikan.',
        'waktu' : h1,
      });
    }

    // H (hari deadline): custom atau 2 jam sebelum
    DateTime notifH;
    if (task.useCustomNotif && task.customNotifHour != null) {
      notifH = DateTime(
        d.year, d.month, d.day,
        task.customNotifHour!,
        task.customNotifMinute ?? 0,
      );
    } else {
      notifH = d.subtract(const Duration(hours: 2));
      // Jaga-jaga agar tetap di hari yang sama
      if (notifH.day != d.day) {
        notifH = DateTime(d.year, d.month, d.day, 7, 0);
      }
    }

    if (notifH.isAfter(now)) {
      jadwal.add({
        'id'    : task.id * 10 + 3,
        'judul' : '🔥 DEADLINE HARI INI!',
        'pesan' : '$nama — HARI INI deadline! Kumpulkan sekarang.',
        'waktu' : notifH,
      });
    }

    return jadwal;
  }

  // ────────────────────────────────────────────────────────────────────────────
  // PUBLIC API
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> jadwalkanNotifikasiTugas(Task task) async {
    if (!_initialized) {
      if (kDebugMode) debugPrint('⚠️ jadwalkan: service belum init');
      return;
    }
    if (task.isSelesai) {
      if (kDebugMode) debugPrint('⚠️ jadwalkan: task sudah selesai, skip');
      return;
    }

    try {
      final jadwal = _hitungJadwal(task);
      if (jadwal.isEmpty && kDebugMode) {
        debugPrint('⚠️ Tidak ada jadwal untuk task ${task.namaTugas} (semua sudah lewat?)');
      }

      for (final item in jadwal) {
        await _jadwalkan(
          id    : item['id']    as int,
          judul : item['judul'] as String,
          pesan : item['pesan'] as String,
          waktu : item['waktu'] as DateTime,
        );
        await HiveService.simpanLogNotifikasi(
          judul     : item['judul'] as String,
          pesan     : item['pesan'] as String,
          waktu     : item['waktu'] as DateTime,
          taskId    : task.id,
          namaTugas : task.namaTugas,
        );
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('❌ jadwalkanNotifikasiTugas error: $e');
        debugPrint(st.toString());
      }
    }
  }

  Future<void> batalkanNotifikasiTugas(int taskId) async {
    if (!_initialized) return;
    try {
      await Future.wait([
        _plugin.cancel(taskId * 10 + 1),
        _plugin.cancel(taskId * 10 + 2),
        _plugin.cancel(taskId * 10 + 3),
      ]);
      if (kDebugMode) debugPrint('🗑️ Notifikasi dibatalkan untuk taskId=$taskId');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ batalkanNotifikasiTugas error: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // INTERNAL SCHEDULE
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> _jadwalkan({
    required int      id,
    required String   judul,
    required String   pesan,
    required DateTime waktu,
  }) async {
    try {
      final tzWaktu  = tz.TZDateTime.from(waktu, tz.local);
      final tzNow    = tz.TZDateTime.now(tz.local);

      if (tzWaktu.isBefore(tzNow)) {
        if (kDebugMode) debugPrint('⏭️ Skip (sudah lewat): id=$id | $waktu');
        return;
      }

      // Coba dengan ic_stat_icon dulu
      NotificationDetails details;
      try {
        details = NotificationDetails(android: _buildAndroidDetails(iconName: 'ic_stat_icon'));
      } catch (_) {
        // Fallback ke icon default jika ic_stat_icon tidak ada
        details = NotificationDetails(android: _buildAndroidDetails(iconName: null));
      }

      await _plugin.zonedSchedule(
        id,
        judul,
        pesan,
        tzWaktu,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      if (kDebugMode) {
        debugPrint('✅ Dijadwalkan: id=$id | "$judul" | $waktu');
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('❌ _jadwalkan error (id=$id): $e');
        debugPrint(st.toString());
      }
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // TEST — panggil dari tombol debug
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> testNotifikasiSekarang() async {
    if (!_initialized) {
      if (kDebugMode) debugPrint('❌ test: service belum init');
      return;
    }
    try {
      await _plugin.show(
        99999,
        '🔔 Test Notifikasi TugasKu',
        'Jika ini muncul, notifikasi berfungsi normal!',
        NotificationDetails(android: _buildAndroidDetails()),
      );
      if (kDebugMode) debugPrint('✅ Test notifikasi dikirim');
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('❌ testNotifikasiSekarang error: $e');
        debugPrint(st.toString());
      }
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // CEK STATUS (untuk debug screen)
  // ────────────────────────────────────────────────────────────────────────────
  bool get isInitialized => _initialized;

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized) return [];
    return await _plugin.pendingNotificationRequests();
  }
}
