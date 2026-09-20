import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'pro_provider.g.dart';

// llaves para guardar en SharedPreferences
// las guardamos como constantes para no arriesgarnos a escribir mal el string
// en diferentes partes del codigo (typo = bug dificil de encontrar)
const _proKey = 'is_pro_user';
const _notificationsKey = 'notifications_enabled';

@riverpod
class ProStatus extends _$ProStatus {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    // si la llave no existe todavia, regresa false por default
    return prefs.getBool(_proKey) ?? false;
  }

  Future<void> setPro(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_proKey, value);
    // aqui no hace falta llamar a Isar ni nada, solo actualizamos el state
    // ref.invalidateSelf() vuelve a correr el build() de arriba, que ya va a leer el nuevo valor
    ref.invalidateSelf();
    await future;
  }
}

@riverpod
class NotificationsSetting extends _$NotificationsSetting {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
    ref.invalidateSelf();
    await future;
  }
}
