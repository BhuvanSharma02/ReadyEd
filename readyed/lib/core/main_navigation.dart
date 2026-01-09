import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../features/home/enhanced_home_screen.dart';
import '../features/content/all_disasters_screen.dart';
import '../features/drills/drills_screen.dart';
import '../features/alerts/alerts_screen.dart';
import '../features/profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  
  static const List<Widget> _screens = [
    EnhancedHomeScreen(),
    AllDisastersScreen(),
    DrillsScreen(),
    AlertsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house, size: 20),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.book, size: 20),
            label: 'Disasters',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.brain, size: 20),
            label: 'Scenarios',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.triangleExclamation, size: 20),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.user, size: 20),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}