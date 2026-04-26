import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../models/mata_kuliah_model.dart';

class HiveService {
  static const String _taskBoxName = 'tasks';
  static const String _mataKuliahBoxName = 'mata_kuliah';
  static const String _settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(MataKuliahAdapter());
    await Hive.openBox<Task>(_taskBoxName);
    await Hive.openBox<MataKuliah>(_mataKuliahBoxName);
    await Hive.openBox(_settingsBoxName);

    // Migrasi: hapus data lama yang di-seed otomatis (versi sebelumnya)
    // agar user bisa mulai fresh dengan mata kuliah sendiri
    final settings = Hive.box(_settingsBoxName);
    final hadOldSeed = settings.get('seededMataKuliah', defaultValue: false) as bool;
    final migratedClean = settings.get('migratedClean', defaultValue: false) as bool;
    if (hadOldSeed && !migratedClean) {
      // Hapus semua data lama
      await Hive.box<Task>(_taskBoxName).clear();
      await Hive.box<MataKuliah>(_mataKuliahBoxName).clear();
      await settings.put('seededMataKuliah', false);
      await settings.put('migratedClean', true);
      // Jangan hapus isFirstLaunch supaya tidak tampil onboarding lagi
    }
  }

  static Box<Task> getTaskBox() => Hive.box<Task>(_taskBoxName);
  static Box<MataKuliah> getMataKuliahBox() =>
      Hive.box<MataKuliah>(_mataKuliahBoxName);
  static Box getSettingsBox() => Hive.box(_settingsBoxName);

  static int _dateKey(DateTime dt) => dt.year * 10000 + dt.month * 100 + dt.day;

  /// Returns true only on the very first app launch, then flips the flag.
  static bool getIsFirstLaunch() {
    final box = Hive.box(_settingsBoxName);
    final isFirst = box.get('isFirstLaunch', defaultValue: true) as bool;
    if (isFirst) box.put('isFirstLaunch', false);
    return isFirst;
  }

  /// Allocate an incrementing id (small int) so keys stay unique and
  /// notification ids remain within safe bounds.
  static Future<int> allocateTaskId() async {
    final settings = getSettingsBox();
    int? next = settings.get('nextTaskId') as int?;
    final keys = getTaskBox().keys.whereType<int>();
    var maxKey = 0;
    for (final k in keys) {
      if (k > maxKey) maxKey = k;
    }
    if (next == null || next <= maxKey) next = maxKey + 1;
    await settings.put('nextTaskId', next + 1);
    return next;
  }

  static Future<int> allocateMataKuliahId() async {
    final settings = getSettingsBox();
    int? next = settings.get('nextMataKuliahId') as int?;
    final keys = getMataKuliahBox().keys.whereType<int>();
    var maxKey = 0;
    for (final k in keys) {
      if (k > maxKey) maxKey = k;
    }
    if (next == null || next <= maxKey) next = maxKey + 1;
    await settings.put('nextMataKuliahId', next + 1);
    return next;
  }

  static int getFocusTotalMinutes() =>
      getSettingsBox().get('focusTotalMinutes', defaultValue: 0) as int;
  static int getFocusStreakDays() =>
      getSettingsBox().get('focusStreakDays', defaultValue: 0) as int;

  static Future<void> addFocusMinutes(int minutes) async {
    if (minutes <= 0) return;
    final settings = getSettingsBox();

    final total =
        (settings.get('focusTotalMinutes', defaultValue: 0) as int) + minutes;
    await settings.put('focusTotalMinutes', total);

    final now = DateTime.now();
    final todayKey = _dateKey(now);
    final yesterdayKey = _dateKey(now.subtract(const Duration(days: 1)));

    final lastKey = settings.get('focusLastDayKey', defaultValue: 0) as int;
    var streak = settings.get('focusStreakDays', defaultValue: 0) as int;

    if (lastKey == todayKey) {
      // already counted for today
    } else if (lastKey == yesterdayKey) {
      streak = streak <= 0 ? 1 : streak + 1;
    } else {
      streak = 1;
    }

    await settings.put('focusLastDayKey', todayKey);
    await settings.put('focusStreakDays', streak);
  }

  static Future<void> resetAllData() async {
    await getTaskBox().clear();
    await getMataKuliahBox().clear();
    // Hapus semua settings kecuali migratedClean agar migrasi tidak jalan lagi
    await getSettingsBox().delete('nextTaskId');
    await getSettingsBox().delete('nextMataKuliahId');
    await getSettingsBox().delete('focusTotalMinutes');
    await getSettingsBox().delete('focusStreakDays');
    await getSettingsBox().delete('focusLastDayKey');
    await getSettingsBox().delete('seededMataKuliah');
    await getSettingsBox().delete('isFirstLaunch');
  }
}
