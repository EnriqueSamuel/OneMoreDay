import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pro_provider.dart';
import '../services/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProAsync = ref.watch(proStatusProvider);
    final notificationsAsync = ref.watch(notificationsSettingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          // seccion Pro, usamos .when otra vez porque leer de SharedPreferences es async
          isProAsync.when(
            loading: () => const ListTile(title: Text('Cargando...')),
            error: (e, s) => ListTile(title: Text('Error: $e')),
            data: (isPro) {
              if (isPro) {
                return const ListTile(
                  leading: Icon(Icons.workspace_premium, color: Colors.amber),
                  title: Text('Ya eres usuario Pro'),
                  subtitle: Text('Gracias por tu apoyo'),
                );
              }
              return ListTile(
                leading: const Icon(Icons.workspace_premium),
                title: const Text('Hazte Pro'),
                subtitle: const Text('Sin anuncios y contadores ilimitados'),
                trailing: FilledButton(
                  // por ahora esto solo cambia el flag, en el paso de monetizacion
                  // real aqui va a ir la logica de compra con in_app_purchase
                  onPressed: () {
                    ref.read(proStatusProvider.notifier).setPro(true);
                  },
                  child: const Text('Comprar'),
                ),
              );
            },
          ),

          const Divider(),

          // switch de notificaciones
          notificationsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, s) => const SizedBox.shrink(),
            data: (enabled) {
              return SwitchListTile(
                title: const Text('Notificaciones diarias'),
                subtitle: const Text('Recordatorio para revisar tus rachas'),
                value: enabled,
                onChanged: (value) async {
                  // primero actualizamos la preferencia guardada
                  await ref
                      .read(notificationsSettingProvider.notifier)
                      .setEnabled(value);

                  // y aqui si conectamos con el servicio real
                  // el provider solo guarda "true/false", el servicio es el que
                  // de verdad programa o cancela la notificacion en el sistema
                  if (value) {
                    final granted =
                        await NotificationService.requestPermissions();
                    if (granted) {
                      await NotificationService.scheduleDailyReminder(
                        hour: 20,
                        minute: 0,
                      );
                    }
                  } else {
                    await NotificationService.cancelDailyReminder();
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
