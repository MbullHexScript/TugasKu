import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../models/mata_kuliah_model.dart';

class HiveService {
  static const String _taskBoxName = 'tasks';
  static const String _mataKuliahBoxName = 'mata_kuliah';
  static const String _settingsBoxName = 'settings';

  static const String _profileNameKey = 'profileName';
  static const String _profileProgramKey = 'profileProgram';
  static const String _profileSemesterKey = 'profileSemester';
  static const String _profilePhotoKey = 'profilePhoto'; // ← TAMBAH

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(MataKuliahAdapter());
    await Hive.openBox<Task>(_taskBoxName);
    await Hive.openBox<MataKuliah>(_mataKuliahBoxName);
    await Hive.openBox(_settingsBoxName);

    final settings = Hive.box(_settingsBoxName);
    final hadOldSeed =
        settings.get('seededMataKuliah', defaultValue: false) as bool;
    final migratedClean =
        settings.get('migratedClean', defaultValue: false) as bool;
    if (hadOldSeed && !migratedClean) {
      await Hive.box<Task>(_taskBoxName).clear();
      await Hive.box<MataKuliah>(_mataKuliahBoxName).clear();
      await settings.put('seededMataKuliah', false);
      await settings.put('migratedClean', true);
    }
  }

  static Box<Task> getTaskBox() => Hive.box<Task>(_taskBoxName);
  static Box<MataKuliah> getMataKuliahBox() =>
      Hive.box<MataKuliah>(_mataKuliahBoxName);
  static Box getSettingsBox() => Hive.box(_settingsBoxName);

  static int _dateKey(DateTime dt) =>
      dt.year * 10000 + dt.month * 100 + dt.day;

  static bool getIsFirstLaunch() {
    final box = Hive.box(_settingsBoxName);
    final isFirst = box.get('isFirstLaunch', defaultValue: true) as bool;
    if (isFirst) {
      unawaited(box.put('isFirstLaunch', false));
    }
    return isFirst;
  }

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
    await getSettingsBox().delete('nextTaskId');
    await getSettingsBox().delete('nextMataKuliahId');
    await getSettingsBox().delete('focusTotalMinutes');
    await getSettingsBox().delete('focusStreakDays');
    await getSettingsBox().delete('focusLastDayKey');
    await getSettingsBox().delete('seededMataKuliah');
    await getSettingsBox().delete('isFirstLaunch');
    await getSettingsBox().delete(_profileNameKey);
    await getSettingsBox().delete(_profileProgramKey);
    await getSettingsBox().delete(_profileSemesterKey);
    await getSettingsBox().delete(_profilePhotoKey); // ← TAMBAH
  }

  // ── Profile ────────────────────────────────────────────────────────────────
  static String getProfileName() =>
      getSettingsBox().get(_profileNameKey, defaultValue: 'Mahasiswa')
          as String;

  static String getProfileProgram() => getSettingsBox()
      .get(_profileProgramKey, defaultValue: 'Teknik Informatika') as String;

  static int getProfileSemester() =>
      getSettingsBox().get(_profileSemesterKey, defaultValue: 5) as int;

  // ← TAMBAH: getter & setter foto profil
  static String? getProfilePhoto() =>
      getSettingsBox().get(_profilePhotoKey) as String?;

  static Future<void> setProfilePhoto(String path) async {
    await getSettingsBox().put(_profilePhotoKey, path);
  }

  static Future<void> setProfile({
    required String name,
    required String program,
    required int semester,
  }) async {
    final box = getSettingsBox();
    await box.put(_profileNameKey, name);
    await box.put(_profileProgramKey, program);
    await box.put(_profileSemesterKey, semester);
  }
}
