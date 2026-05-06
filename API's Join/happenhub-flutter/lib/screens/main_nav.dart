import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'events/home_screen.dart';
import 'saved/saved_events_screen.dart';
import 'profile/profile_screen.dart';
import 'events/create_event_screen.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

/// Main bottom navigation wrapper for the authenticated app.
class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _currentIndex = 0;
  bool _isBusiness = false;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(AppConstants.userRoleKey) ?? 'USER';
    setState(() => _isBusiness = role == 'BUSINESS');
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const SavedEventsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),

      // ── FAB for business users ──────────────────────────
      floatingActionButton: _isBusiness
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateEventScreen()),
              ),
              backgroundColor: AppTheme.accent,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,

      // ── Bottom nav ──────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore_rounded),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline_rounded),
            activeIcon: Icon(Icons.favorite_rounded),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
