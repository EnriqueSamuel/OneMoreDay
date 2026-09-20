import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/counter_provider.dart';
import '../models/counter_model.dart';

// lista de emojis para elegir, simple y rapido, nada de plugins pesados
const _emojiOptions = [
  '🔥',
  '💪',
  '📚',
  '🚭',
  '💧',
  '🏃',
  '😴',
  '🧘',
  '💰',
  '🎯',
];

// lista de colores para elegir
const _colorOptions = [
  Colors.deepPurple,
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.red,
  Colors.teal,
];

// ConsumerStatefulWidget = ConsumerWidget + StatefulWidget combinados
// lo necesitas cuando la pantalla tiene estado propio (lo que el usuario va llenando)
// Y ademas necesita leer/escribir providers
class CreateCounterScreen extends ConsumerStatefulWidget {
  const CreateCounterScreen({super.key});

  @override
  ConsumerState<CreateCounterScreen> createState() =>
      _CreateCounterScreenState();
}

class _CreateCounterScreenState extends ConsumerState<CreateCounterScreen> {
  // controller para leer lo que el usuario escribe en el campo de nombre
  final _nameController = TextEditingController();

  // estas variables guardan lo que el usuario va eligiendo
  // "late" no aplica aqui porque les damos valor por default de una vez
  String _selectedEmoji = _emojiOptions.first;
  Color _selectedColor = _colorOptions.first;
  DateTime _selectedDate = DateTime.now();
  CounterType _selectedType = CounterType.streak;

  // esto es obligatorio: cuando el widget se destruye, hay que liberar el controller
  // si no lo haces, se queda "vivo" en memoria sin necesidad (memory leak)
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      // setState le dice a Flutter "algo cambio, vuelve a dibujar este widget"
      // esto SOLO aplica a estado local de la pantalla, no al de Isar
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveCounter() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ponle un nombre a tu contador')),
      );
      return;
    }

    final counter = CounterModel()
      ..name = name
      ..emoji = _selectedEmoji
      ..colorValue = _selectedColor.value
      ..startDate = _selectedDate
      ..type = _selectedType;

    // ref.read (no watch) porque aqui solo queremos EJECUTAR una accion, no escuchar cambios
    // watch es para leer y reaccionar, read es para llamar un metodo una sola vez
    await ref.read(counterListProvider.notifier).addCounter(counter);

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo contador')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              hintText: 'ej. Dias sin fumar, Racha de ejercicio',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          const Text('Icono', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _emojiOptions.map((emoji) {
              final isSelected = emoji == _selectedEmoji;
              return GestureDetector(
                onTap: () => setState(() => _selectedEmoji = emoji),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? Colors.deepPurple : Colors.grey,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _colorOptions.map((color) {
              final isSelected = color == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.black, width: 3)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          const Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold)),
          SegmentedButton<CounterType>(
            segments: const [
              ButtonSegment(
                value: CounterType.streak,
                label: Text('Racha (cuenta hacia arriba)'),
              ),
              ButtonSegment(
                value: CounterType.countdown,
                label: Text('Cuenta regresiva'),
              ),
            ],
            selected: {_selectedType},
            onSelectionChanged: (selection) {
              setState(() => _selectedType = selection.first);
            },
          ),
          const SizedBox(height: 24),

          const Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _pickDate,
            child: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            ),
          ),
          const SizedBox(height: 32),

          FilledButton(
            onPressed: _saveCounter,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }
}
