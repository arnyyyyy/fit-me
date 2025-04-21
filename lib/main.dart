import 'package:fit_me/repositories/hive_repository.dart';
import 'package:fit_me/screens/main_screen.dart';
import 'package:fit_me/services/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveRepository.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainScreen(),
      onGenerateRoute: RoutesBuilder.onGenerateRoute,
      routes: RoutesBuilder.routes,
    );
  }
}
