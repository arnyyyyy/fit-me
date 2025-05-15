import 'package:fit_me/features/calendar/view/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../wardrobe/view/main_wardrobe_screen.dart';
import '../collages/view/main_collages_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialTabIndex;

  const MainScreen({super.key, this.initialTabIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
  }

  final List<Widget> _screens = const [
    CollagesScreen(),
    CalendarScreen(),
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
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.checkroom_outlined),
              activeIcon: const Icon(Icons.checkroom, color: AppColors.primary),
              label: AppLocalizations.of(context).collagesTabLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_month),
              activeIcon: const Icon(Icons.calendar_month, color: AppColors.primary),
              label: AppLocalizations.of(context).calendar,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.door_sliding_outlined),
              activeIcon: const Icon(Icons.door_sliding, color: AppColors.primary),
              label: AppLocalizations.of(context).wardrobeTabLabel,
            ),
          ],
        ),
      ),
    );
  }
}
