import 'package:fit_me/features/screens/select_image_screen.dart';
import 'package:flutter/material.dart';

import '../../features/wardrobe/view/main_wardrobe_screen.dart';
import '../../features/collages/collage_screen.dart';
import '../../features/screens/main_screen.dart';

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
    RouteNames.allClothes: (_) => const WardrobeScreen(),
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
          builder: (_) => const WardrobeScreen(),
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