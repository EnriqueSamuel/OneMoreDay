import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/counter_model.dart';
import '../services/isar_service.dart';

part 'counter_provider.g.dart'; // Ruta relativa corregida

@riverpod
class CounterList extends _$CounterList {
  @override
  Future<List<CounterModel>> build() async {
    return IsarService.getAllCounters();
  }

  Future<void> addCounter(CounterModel counter) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await IsarService.addCounter(counter);
      return IsarService.getAllCounters();
    });
  }

  Future<void> updateCounter(CounterModel counter) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await IsarService.updateCounter(counter);
      return IsarService.getAllCounters();
    });
  }

  Future<void> deleteCounter(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await IsarService.deleteCounter(id);
      return IsarService.getAllCounters();
    });
  }

  Future<void> resetStreak(CounterModel counter) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await IsarService.resetStreak(counter);
      return IsarService.getAllCounters();
    });
  }
}
