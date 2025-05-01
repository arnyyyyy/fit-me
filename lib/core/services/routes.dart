import 'package:fit_me/features/collages/view/main_collages_screen.dart';
import 'package:flutter/material.dart';

import '../../features/wardrobe/view/main_wardrobe_screen.dart';
import '../../features/main/main_screen.dart';

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
      return const CollagesScreen();
    },
    RouteNames.allCollages: (_) => const CollagesScreen(),
    RouteNames.allClothes: (_) => const WardrobeScreen(),
    RouteNames.main: (_) => const MainScreen(),
  };

  static Route<Object?>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) {
            return const CollagesScreen();
          },
          settings: settings,
        );

      case RouteNames.allClothes:
        return MaterialPageRoute(
          builder: (_) => const WardrobeScreen(),
          settings: settings,
        );
      case RouteNames.main:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
          settings: settings,
        );
      case RouteNames.allCollages:
        return MaterialPageRoute(
          builder: (_) => const CollagesScreen(),
          settings: settings,
        );
    }

    return null;
  }
}
