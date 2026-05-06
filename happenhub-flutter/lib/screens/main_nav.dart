import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'events/home_screen.dart';
import 'dashboard/user_dashboard_screen.dart';
import 'dashboard/business_dashboard_screen.dart';
import 'profile/profile_screen.dart';
import 'events/create_event_screen.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

/// Main bottom navigation. Reads role fresh on every build so it stays
/// in sync even if role changes between sessions.
class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _index = 0;
  bool _isBusiness = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(AppConstants.userRoleKey) ?? 'USER';
    if (mounted) setState(() => _isBusiness = role == 'BUSINESS');
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      _isBusiness ? const BusinessDashboardScreen() : const UserDashboardScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_index],

      floatingActionButton: _isBusiness
          ? FloatingActionButton(
              onPressed: () async {
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateEventScreen()),
                );
                if (created == true && mounted) {
                  // Switch to dashboard so user sees their new event
                  setState(() => _index = 1);
                }
              },
              backgroundColor: AppTheme.accent,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore_rounded),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(_isBusiness ? Icons.dashboard_outlined : Icons.favorite_outline_rounded),
            activeIcon: Icon(_isBusiness ? Icons.dashboard_rounded : Icons.favorite_rounded),
            label: _isBusiness ? 'Dashboard' : 'My Events',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
