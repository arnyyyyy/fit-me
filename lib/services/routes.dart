import 'package:fit_me/screens/select_image_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/all_clothes_screen.dart';
import '../screens/collage_screen.dart';
import '../screens/home_screen.dart';

abstract class RouteNames {
  const RouteNames._();

  static const home = '/home';
  static const all_clothes = '/all_clothes';
  static const add_clothes = '/add_clothes';
  static const all_collages = '/all_collages';
  static const add_collages = '/add_collages';
  static const main = '/main';



}

abstract class RoutesBuilder {
  static final routes = <String, Widget Function(BuildContext)>{
    RouteNames.home: (context) {
      return CollageScreen();
    },
    RouteNames.add_clothes: (_) => const SelectImageScreen(),
    RouteNames.all_clothes: (_) => const AllClothesScreen(),
    RouteNames.main: (_) => const MainScreen(),

  };

  static Route<Object?>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) {
            return CollageScreen();
          },
          settings: settings,
        );

      case RouteNames.add_clothes:
        return MaterialPageRoute(
          builder: (_) => const SelectImageScreen(),
          settings: settings,
        );
      case RouteNames.all_clothes:
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