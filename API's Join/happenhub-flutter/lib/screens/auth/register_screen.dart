import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../main_nav.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  bool _obscure = true;
  String _selectedRole = 'USER';

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await _authService.register(
        name:     _nameCtrl.text.trim(),
        email:    _emailCtrl.text.trim(),
        password: _passCtrl.text,
        role:     _selectedRole,
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
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
                ),

                const SizedBox(height: 32),

                Text('Create Account', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 6),
                const Text('Join HappenHub and explore local events.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),

                const SizedBox(height: 36),

                AppTextField(
                  controller: _nameCtrl,
                  label: 'Full Name',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Name is required';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

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
                      size: 18, color: AppTheme.textSecondary,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ── Role selector ─────────────────────────
                const Text('Account Type', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _roleOption('USER', '👤 Regular User'),
                    const SizedBox(width: 12),
                    _roleOption('BUSINESS', '🏢 Business'),
                  ],
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? const SizedBox(
                            height: 22, width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white,
                            ),
                          )
                        : const Text('Create Account'),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ",
                        style: TextStyle(color: AppTheme.textSecondary)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Sign In',
                          style: TextStyle(
                            color: AppTheme.accent, fontWeight: FontWeight.w600,
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

  Widget _roleOption(String role, String label) {
    final selected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppTheme.accent.withOpacity(0.15) : AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppTheme.accent : AppTheme.divider,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppTheme.accent : AppTheme.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
