import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleGoogleSignIn() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();

    if (mounted) {
      final authState = ref.read(authControllerProvider);
      if (authState.user != null) {
        context.go(RouteConstants.home);
      } else if (authState.error != null) {
        _showError(authState.error!);
      }
    }
  }

  void _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isSignUp) {
      await ref.read(authControllerProvider.notifier).signUpWithEmailPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
          );
    } else {
      await ref.read(authControllerProvider.notifier).signInWithEmailPassword(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }

    if (mounted) {
      final authState = ref.read(authControllerProvider);
      if (authState.user != null) {
        context.go(RouteConstants.home);
      } else if (authState.error != null) {
        _showError(authState.error!);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF060D1A),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.1),
            radius: 1.3,
            colors: [
              Color(0xFF0D2137),
              Color(0xFF060D1A),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo
                Center(
                  child: Image.asset(
                    'assets/logo/logotravl.png',
                    width: size.width * 0.42,
                    height: size.width * 0.42,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Travl',
                  style: AppTextStyles.h1.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('plan_adventures_together'),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Email/Password Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_isSignUp)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              label: context.tr('name'),
                              icon: Icons.person_outline,
                            ),
                            validator: (value) =>
                                Validators.required(value, context.tr('name')),
                          ),
                        ),

                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: context.tr('email'),
                          icon: Icons.email_outlined,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: context.tr('password'),
                          icon: Icons.lock_outline,
                        ),
                        obscureText: true,
                        validator: (value) =>
                            Validators.required(value, 'Password'),
                      ),

                      const SizedBox(height: 24),

                      // Email Auth Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                              authState.isLoading ? null : _handleEmailAuth,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: authState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : Text(
                                  _isSignUp
                                      ? context.tr('sign_up')
                                      : context.tr('sign_in'),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Toggle Sign In/Sign Up
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignUp = !_isSignUp;
                    });
                  },
                  child: Text(
                    _isSignUp
                        ? context.tr('already_have_account')
                        : context.tr('no_account_sign_up'),
                    style:
                        TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  ),
                ),

                const SizedBox(height: 32),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child:
                          Divider(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        context.tr('or'),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    Expanded(
                      child:
                          Divider(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Google Sign In Button
                AuthButton(
                  onPressed: authState.isLoading ? null : _handleGoogleSignIn,
                  label: context.tr('continue_with_google'),
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  useGoogleLogo: true,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
      prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.5)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
