import 'package:isar/isar.dart';

part 'counter_model.g.dart'; // Cambiado a ruta relativa}

enum CounterType { streak, countdown }

@collection
class CounterModel {
  Id id = Isar.autoIncrement;
  late String name;
  late String emoji;
  late int colorValue;
  late DateTime startDate;

  @enumerated
  late CounterType type;

  int previousRecord = 0;
  bool notificationsEnabled = false;
  DateTime createdAt = DateTime.now();

  @ignore
  int get daysElapsed {
    final now = DateTime.now();
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final today = DateTime(now.year, now.month, now.day);

    if (type == CounterType.streak) {
      return today.difference(start).inDays;
    } else {
      return start.difference(today).inDays;
    }
  }
}
