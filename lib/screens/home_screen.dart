import 'package:flutter/material.dart';
import 'package:fit_me/screens/all_clothes_screen.dart';
import 'package:fit_me/screens/collage_screen.dart';
import 'package:fit_me/screens/select_image_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  // Список всех экранов по порядку
  final List<Widget> _screens = const [
    CollageScreen(),
    SelectImageScreen(),
    AllClothesScreen(),
  ];

  final List<String> _titles = [
    'Коллажи',
    'Добавить одежду',
    'Вся одежда',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Коллажи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_a_photo),
            label: 'Добавить',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom),
            label: 'Одежда',
          ),
        ],
      ),
    );
  }
}
