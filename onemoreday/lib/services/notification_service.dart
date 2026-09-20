import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  // instancia del plugin, la reusamos en todo el servicio
  static final _plugin = FlutterLocalNotificationsPlugin();

  // esto SI se llama una sola vez al arrancar la app, a diferencia de Isar
  // (que abre "solito" cuando se necesita), las notificaciones necesitan
  // configurarse antes de poder pedir permisos o programar cualquier cosa
  static Future<void> init() async {
    // esto carga la base de datos de zonas horarias del mundo
    // sin esto, "programar para las 8pm" no sabe a que 8pm te refieres
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
  }

  // en android 13+ y en ios, tienes que pedir permiso explicito
  // antes no hacia falta, ahora si o si truena en silencio si no lo pides
  static Future<bool> requestPermissions() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    final androidGranted =
        await androidPlugin?.requestNotificationsPermission() ?? true;
    final iosGranted =
        await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;

    return androidGranted && iosGranted;
  }

  // programa UNA notificacion diaria repetida a la hora que le pases
  // por ejemplo scheduleDailyReminder(hour: 20, minute: 0) = todos los dias a las 8pm
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // si la hora que pediste ya paso hoy, se programa para mañana
    // sin esto, si son las 9pm y pides notificar a las 8pm, se dispararia de inmediato
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      // id fijo porque solo manejamos UN recordatorio diario por ahora
      // si mas adelante quieres notificaciones por contador, cada una necesita su propio id
      0,
      'No rompas tu racha',
      'Ya casi es de noche, revisa tus contadores en OneMoreDay',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Recordatorio diario',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // esto es lo que hace que se repita CADA DIA a esa hora, no solo una vez
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelDailyReminder() async {
    await _plugin.cancel(0);
  }
}
