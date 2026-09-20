import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/counter_provider.dart';
import '../models/counter_model.dart';

// esta pantalla SI puede ser ConsumerWidget normal (no statefull)
// porque no tiene estado propio que ir llenando, solo muestra datos y ejecuta acciones
class CounterDetailScreen extends ConsumerWidget {
  // recibimos el contador directo desde la pantalla anterior
  // esto se le llama "pasar datos por constructor", es la forma mas simple de compartir
  // datos entre 2 pantallas sin meter un provider extra para algo tan puntual
  final CounterModel counter;

  const CounterDetailScreen({super.key, required this.counter});

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    // showDialog regresa lo que el usuario elija, por eso lo guardamos en "confirmed"
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reiniciar racha'),
        content: Text(
          'Vas a reiniciar "${counter.name}" desde 0. '
          'Tu record de ${counter.daysElapsed} dias se va a guardar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );

    // si confirmed es null (cerro el dialog tocando afuera) o false, no hacemos nada
    if (confirmed == true) {
      await ref.read(counterListProvider.notifier).resetStreak(counter);
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar contador'),
        content: Text('Se va a borrar "${counter.name}" para siempre.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(counterListProvider.notifier).deleteCounter(counter.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStreak = counter.type == CounterType.streak;

    return Scaffold(
      appBar: AppBar(
        title: Text(counter.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(counter.emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              '${counter.daysElapsed}',
              style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
            ),
            Text(
              isStreak ? 'dias' : 'dias restantes',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // el record solo tiene sentido en una racha, no en cuenta regresiva
            // por eso lo mostramos condicional
            if (isStreak && counter.previousRecord > 0)
              Text(
                'Tu record: ${counter.previousRecord} dias',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),

            const SizedBox(height: 32),

            // el boton de reiniciar solo aplica a rachas
            // una cuenta regresiva no se "reinicia", se edita la fecha si acaso
            if (isStreak)
              OutlinedButton.icon(
                onPressed: () => _confirmReset(context, ref),
                icon: const Icon(Icons.refresh),
                label: const Text('Reiniciar racha'),
              ),
          ],
        ),
      ),
    );
  }
}
