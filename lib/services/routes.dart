import 'package:fit_me/screens/select_image_screen.dart';
import 'package:flutter/material.dart';

import '../clothes/all_clothes_screen.dart';
import '../screens/collage_screen.dart';
import '../screens/home_screen.dart';

abstract class RouteNames {
  const RouteNames._();

  static const home = '/home';
  static const allClothes = '/all_clothes';
  static const addClothes = '/add_clothes';
  static const allCollages = '/all_collages';
  static const addCollages = '/add_collages';
  static const main = '/main';



}

abstract class RoutesBuilder {
  static final routes = <String, Widget Function(BuildContext)>{
    RouteNames.home: (context) {
      return const CollageScreen();
    },
    RouteNames.addClothes: (_) => const SelectImageScreen(),
    RouteNames.allClothes: (_) => const AllClothesScreen(),
    RouteNames.main: (_) => const MainScreen(),

  };

  static Route<Object?>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) {
            return const CollageScreen();
          },
          settings: settings,
        );

      case RouteNames.addClothes:
        return MaterialPageRoute(
          builder: (_) => const SelectImageScreen(),
          settings: settings,
        );
      case RouteNames.allClothes:
        return MaterialPageRoute(
          builder: (_) => const AllClothesScreen(),
          settings: settings,
        );
      case RouteNames.main:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
          settings: settings,
        );

    }

    return null;
  }
}