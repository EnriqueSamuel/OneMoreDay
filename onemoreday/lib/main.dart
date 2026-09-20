import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // este si lo llamamos a fuerzas aqui, a diferencia de Isar
  // porque necesitamos el plugin listo antes de poder pedir permisos o programar nada
  await NotificationService.init();

  runApp(const ProviderScope(child: OneMoreDayApp()));
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
