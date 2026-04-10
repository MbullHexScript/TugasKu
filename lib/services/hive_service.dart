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
  }

  static Box<Task> getTaskBox() => Hive.box<Task>(_taskBoxName);
  static Box<MataKuliah> getMataKuliahBox() =>
      Hive.box<MataKuliah>(_mataKuliahBoxName);
  static Box getSettingsBox() => Hive.box(_settingsBoxName);

  /// Returns true only on the very first app launch, then flips the flag.
  static bool getIsFirstLaunch() {
    final box = Hive.box(_settingsBoxName);
    final isFirst = box.get('isFirstLaunch', defaultValue: true) as bool;
    if (isFirst) box.put('isFirstLaunch', false);
    return isFirst;
  }
}
