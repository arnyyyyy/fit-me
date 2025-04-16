import 'package:fit_me/saved_image.dart';
import 'package:fit_me/screens/home_screen.dart';
import 'package:fit_me/services/routes.dart';
import 'package:fit_me/tag.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);
  Hive.registerAdapter(SavedImageAdapter());
  Hive.registerAdapter(TagAdapter());


  await Hive.openBox<SavedImage>('imagesBox');
  await Hive.openBox<Tag>('tagsBox');



  runApp(const MyApp());
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
