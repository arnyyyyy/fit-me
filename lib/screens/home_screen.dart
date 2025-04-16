import 'package:flutter/material.dart';
import 'package:fit_me/screens/all_clothes_screen.dart';
import 'package:fit_me/screens/collage_screen.dart';
import 'package:fit_me/screens/select_image_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    CollageScreen(),
    SelectImageScreen(),
    AllClothesScreen(),
  ];

  final List<String> _titles = [
    'коллажи',
    'добавить образ',
    'гардероб',
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _titles[_selectedIndex],
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.tagText,
          showUnselectedLabels: true,
          unselectedLabelStyle: AppTextStyles.navLabel,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.image_outlined, color: AppColors.tagText),
              label: 'Коллажи',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_photo_alternate_outlined, color: AppColors.tagText),
              label: 'Добавить',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checkroom_outlined, color: AppColors.tagText,),
              label: 'Гардероб',
            ),
          ],
        ),
      ),
    );
  }
}
