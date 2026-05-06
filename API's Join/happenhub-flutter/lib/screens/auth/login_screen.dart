import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_text_field.dart';
import 'register_screen.dart';
import '../main_nav.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  bool _obscure = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await _authService.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNav()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ── Logo mark ──────────────────────────────
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.accent, AppTheme.accentGold],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('H', style: TextStyle(
                      color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900,
                    )),
                  ),
                ),

                const SizedBox(height: 36),

                Text('Welcome back', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 6),
                const Text('Sign in to discover events near you.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),

                const SizedBox(height: 40),

                AppTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _passCtrl,
                  label: 'Password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscure,
                  suffix: GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                            height: 22, width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white,
                            ),
                          )
                        : const Text('Sign In'),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ",
                        style: TextStyle(color: AppTheme.textSecondary)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      ),
                      child: const Text('Sign Up',
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
