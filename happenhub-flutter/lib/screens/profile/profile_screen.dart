import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../services/api_exception.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';
import '../events/create_event_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name  = '';
  String _email = '';
  String _role  = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name  = prefs.getString(AppConstants.userNameKey)  ?? 'User';
      _email = prefs.getString(AppConstants.userEmailKey) ?? '';
      _role  = prefs.getString(AppConstants.userRoleKey)  ?? 'USER';
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Log out?', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('You will need to sign in again.',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out', style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusiness = _role == 'BUSINESS';
    final initials = _name.trim().isNotEmpty
        ? _name.trim().split(' ').map((s) => s[0]).take(2).join().toUpperCase()
        : 'U';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.accent, AppTheme.accentGold],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(child: Text(initials, style: const TextStyle(
                      color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700,
                    ))),
                  ),
                  const SizedBox(height: 14),
                  Text(_name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(_email, style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 14)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isBusiness ? AppTheme.accent : AppTheme.accentGold)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isBusiness ? AppTheme.accent : AppTheme.accentGold),
                    ),
                    child: Text(
                      isBusiness ? '🏢 Business Account' : '👤 User Account',
                      style: TextStyle(
                        color: isBusiness ? AppTheme.accent : AppTheme.accentGold,
                        fontSize: 13, fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Business: create event shortcut
            if (isBusiness) ...[
              _menuItem(
                icon: Icons.add_circle_outline_rounded,
                label: 'Create New Event',
                subtitle: 'Post an event for your audience',
                accent: true,
                onTap: () async {
                  final created = await Navigator.push<bool>(context,
                    MaterialPageRoute(builder: (_) => const CreateEventScreen()));
                  if (created == true && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Event created! Check Discover.')));
                  }
                },
              ),
              const SizedBox(height: 12),
            ],



            _menuItem(
              icon: Icons.info_outline_rounded,
              label: 'About HappenHub',
              subtitle: 'Version 1.0.0',
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'HappenHub',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 HappenHub',
              ),
            ),
            const SizedBox(height: 12),

            _menuItem(
              icon: Icons.logout_rounded,
              label: 'Log Out',
              subtitle: 'Sign out of your account',
              isDestructive: true,
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool accent = false,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? Colors.redAccent
        : accent ? AppTheme.accent : AppTheme.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(
                    color: color, fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(subtitle, style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
