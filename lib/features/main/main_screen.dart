import 'package:fit_me/features/collage_constructor/view/collage_constructor_screen.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../wardrobe/view/main_wardrobe_screen.dart';
import '../collages/view/main_collages_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;

  final List<Widget> _screens = const [
    CollageConstructorScreen(),
    CollagesScreen(),
    WardrobeScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
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
              icon: Icon(Icons.add_photo_alternate_outlined,
                  color: AppColors.tagText),
              label: 'Добавить',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.image_outlined, color: AppColors.tagText),
              label: 'Коллажи',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.checkroom_outlined,
                color: AppColors.tagText,
              ),
              label: 'Гардероб',
            ),
          ],
        ),
      ),
    );
  }
}
