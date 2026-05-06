import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_nav.dart';
import 'utils/app_theme.dart';

/// Global navigator key — lets ApiClient redirect to login on 401
/// without needing a BuildContext.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Wire up auto-logout on 401
  ApiClient.onUnauthorized = () {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  };

  runApp(const HappenHubApp());
}

class HappenHubApp extends StatelessWidget {
  const HappenHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HappenHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      navigatorKey: navigatorKey,
      home: const SplashScreen(),
    );
  }
}

/// Checks stored JWT and routes to home or login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    );
    _fade  = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.6, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 1600), _navigate);
  }

  Future<void> _navigate() async {
    final user = await AuthService().getStoredUser();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => user != null ? const MainNav() : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.accent, AppTheme.accentGold],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [BoxShadow(
                      color: AppTheme.accent.withOpacity(0.4),
                      blurRadius: 30, offset: const Offset(0, 10),
                    )],
                  ),
                  child: const Center(child: Text('H', style: TextStyle(
                    color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900,
                  ))),
                ),
                const SizedBox(height: 24),
                Text('HappenHub', style: Theme.of(context).textTheme.displayMedium
                    ?.copyWith(letterSpacing: 1.5)),
                const SizedBox(height: 8),
                const Text('Discover what\'s happening near you',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
