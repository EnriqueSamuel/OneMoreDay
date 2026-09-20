import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import '../providers/counter_provider.dart';
import '../models/counter_model.dart';

// esta pantalla deja al usuario elegir CUAL de sus contadores quiere
// ver en el widget de pantalla de inicio, y manda esos datos hacia el widget
class WidgetSetupScreen extends ConsumerStatefulWidget {
  const WidgetSetupScreen({super.key});

  @override
  ConsumerState<WidgetSetupScreen> createState() => _WidgetSetupScreenState();
}

class _WidgetSetupScreenState extends ConsumerState<WidgetSetupScreen> {
  CounterModel? _selectedCounter;
  bool _isSyncing = false;

  // esto es lo que de verdad "manda" los datos hacia el widget nativo
  // home_widget guarda estos datos en un espacio que el widget nativo puede leer
  // (SharedPreferences en android, UserDefaults en ios, son mecanismos del sistema)
  Future<void> _syncWidget() async {
    final counter = _selectedCounter;
    if (counter == null) return;

    setState(() => _isSyncing = true);

    await HomeWidget.saveWidgetData<String>(
      'widget_counter_name',
      counter.name,
    );
    await HomeWidget.saveWidgetData<String>(
      'widget_counter_emoji',
      counter.emoji,
    );
    await HomeWidget.saveWidgetData<int>(
      'widget_counter_days',
      counter.daysElapsed,
    );

    // esto le avisa al sistema operativo "los datos cambiaron, redibuja el widget"
    // el nombre 'OneMoreDayWidgetProvider' tiene que coincidir EXACTO con el que
    // definas del lado nativo de android, si no coincide, no pasa nada (ni error, ni update)
    await HomeWidget.updateWidget(
      name: 'OneMoreDayWidgetProvider',
      androidName: 'OneMoreDayWidgetProvider',
      iOSName: 'OneMoreDayWidget',
    );

    setState(() => _isSyncing = false);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Widget actualizado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final countersAsync = ref.watch(counterListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Widget de pantalla de inicio')),
      body: countersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (counters) {
          if (counters.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Primero crea un contador para poder mostrarlo en tu widget',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // si no hay nada seleccionado todavia, seleccionamos el primero por default
          _selectedCounter ??= counters.first;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Elige que contador quieres ver en tu widget',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<CounterModel>(
                  initialValue: _selectedCounter,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: counters.map((counter) {
                    return DropdownMenuItem(
                      value: counter,
                      child: Text('${counter.emoji} ${counter.name}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCounter = value);
                  },
                ),
                const SizedBox(height: 24),

                FilledButton.icon(
                  onPressed: _isSyncing ? null : _syncWidget,
                  icon: _isSyncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                  label: const Text('Actualizar widget'),
                ),
                const SizedBox(height: 32),

                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Como agregar el widget a tu pantalla de inicio',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Mantén presionada tu pantalla de inicio\n'
                  '2. Toca "Widgets"\n'
                  '3. Busca "OneMoreDay" en la lista\n'
                  '4. Arrastra el widget a tu pantalla',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
