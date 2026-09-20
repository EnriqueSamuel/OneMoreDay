import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/counter_provider.dart';
import '../widgets/counter_card.dart';
import 'create_counter_screen.dart';
import 'counter_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countersAsync = ref.watch(counterListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OneMoreDay'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: countersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Algo salio mal: $error')),
        data: (counters) {
          if (counters.isEmpty) {
            return const _EmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: counters.length,
            itemBuilder: (context, index) {
              final counter = counters[index];
              // ya no armamos el diseño de la tarjeta aqui
              // solo le pasamos el counter y que hacer cuando la toquen
              // eso hace que home_screen.dart sea mas facil de leer de un vistazo
              return CounterCard(
                counter: counter,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CounterDetailScreen(counter: counter),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateCounterScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Aun no tienes contadores',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const Text(
            'Toca el + para crear el primero',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
