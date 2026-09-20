import 'package:flutter/material.dart';
import '../models/counter_model.dart';

// StatelessWidget normal, no ConsumerWidget
// porque esta tarjeta NO necesita leer providers, solo recibe datos y los pinta
// regla simple: si un widget no toca Riverpod ni tiene estado propio, no lo hagas Consumer
class CounterCard extends StatelessWidget {
  final CounterModel counter;
  final VoidCallback onTap;

  const CounterCard({super.key, required this.counter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // reconstruimos el Color de flutter a partir del int que guardamos en isar
    // isar no puede guardar un objeto Color directo, por eso lo guardamos como numero
    final color = Color(counter.colorValue);
    final isStreak = counter.type == CounterType.streak;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // circulo con el color elegido, de fondo detras del emoji
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  counter.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      counter.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      isStreak ? 'Racha' : 'Cuenta regresiva',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                '${counter.daysElapsed}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
