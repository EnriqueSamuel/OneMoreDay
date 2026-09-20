import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/counter_model.dart';

class IsarService {
  static Isar? _isar;

  static Future<Isar> get instance async {
    if (_isar != null) return _isar!;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([CounterModelSchema], directory: dir.path);

    return _isar!;
  }

  static Future<List<CounterModel>> getAllCounters() async {
    final isar = await instance;
    return isar.counterModels.where().sortByCreatedAt().findAll();
  }

  static Future<int> addCounter(CounterModel counter) async {
    final isar = await instance;
    return isar.writeTxn(() async {
      return isar.counterModels.put(counter);
    });
  }

  static Future<void> updateCounter(CounterModel counter) async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.counterModels.put(counter);
    });
  }

  static Future<void> deleteCounter(int id) async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.counterModels.delete(id);
    });
  }

  // para cuando el usuario reinicia una racha, guarda el record si es el mas alto
  static Future<void> resetStreak(CounterModel counter) async {
    final currentDays = counter.daysElapsed;
    if (currentDays > counter.previousRecord) {
      counter.previousRecord = currentDays;
    }
    counter.startDate = DateTime.now();
    await updateCounter(counter);
  }
}
