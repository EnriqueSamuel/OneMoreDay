import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';

void main() async {
  // esto es obligatorio cuando usas async antes de runApp
  // sin esto, cosas como Isar o notificaciones truenan al inicializar
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // ProviderScope es lo que le da vida a Riverpod
    // TODA la app tiene que estar adentro de esto, si no, los providers no funcionan
    const ProviderScope(child: OneMoreDayApp()),
  );
}

class OneMoreDayApp extends StatelessWidget {
  const OneMoreDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneMoreDay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const HomeScreen(),
    );
  }
}
