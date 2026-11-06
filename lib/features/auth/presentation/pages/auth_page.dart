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
import '../widgets/password_reset_dialog.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
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

  Future<void> _showPasswordResetDialog() async {
    final emailSent = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PasswordResetDialog(
        initialEmail: _emailController.text.trim(),
      ),
    );

    if (!mounted || emailSent != true) return;

    _showPasswordResetSuccess();
  }

  void _showPasswordResetSuccess() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.tr('auth_reset_email_sent')),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return context.tr('auth_error_invalid_credentials');

      case 'email-already-in-use':
        return context.tr('auth_error_email_in_use');

      case 'weak-password':
        return context.tr('auth_error_weak_password');

      case 'network-request-failed':
        return context.tr('auth_error_network');

      case 'too-many-requests':
        return context.tr('auth_error_too_many_requests');

      case 'user-disabled':
        return context.tr('auth_error_user_disabled');

      case 'operation-not-allowed':
        return context.tr('auth_error_operation_not_allowed');

      default:
        return context.tr('auth_error_generic');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();

    if (!mounted) return;

    final authState = ref.read(authControllerProvider);

    if (authState.user != null) {
      context.go(RouteConstants.home);
    } else if (authState.error != null) {
      _showError(_getAuthErrorMessage(authState.error!));
    }
  }

  String? _validateInputs() {
    if (_isSignUp) {
      final nameError = Validators.required(
        _nameController.text,
        context.tr('name'),
        requiredMessage: context.tr('auth_name_required'),
      );

      if (nameError != null) return nameError;
    }

    final emailError = Validators.email(
      _emailController.text,
      requiredMessage: context.tr('auth_email_required'),
      invalidMessage: context.tr('auth_email_invalid'),
    );

    if (emailError != null) return emailError;

    final passwordError = Validators.required(
      _passwordController.text,
      context.tr('password'),
      requiredMessage: context.tr('auth_password_required'),
    );

    if (passwordError != null) return passwordError;

    return null;
  }

  Future<void> _handleEmailAuth() async {
    final validationError = _validateInputs();

    if (validationError != null) {
      _showError(validationError);
      return;
    }

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

    if (!mounted) return;

    final authState = ref.read(authControllerProvider);

    if (authState.user != null) {
      context.go(RouteConstants.home);
    } else if (authState.error != null) {
      _showError(_getAuthErrorMessage(authState.error!));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  void _toggleAuthMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final size = MediaQuery.of(context).size;
    final isLoading = authState.isLoading;

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

                // Authentication form
                Column(
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
                      textInputAction: TextInputAction.next,
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
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted:
                          isLoading ? null : (_) => _handleEmailAuth(),
                    ),
                    if (!_isSignUp)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed:
                              isLoading ? null : _showPasswordResetDialog,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            context.tr('auth_forgot_password'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleEmailAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: isLoading
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

                const SizedBox(height: 16),

                // Switch between login and signup
                TextButton(
                  onPressed: isLoading ? null : _toggleAuthMode,
                  child: Text(
                    _isSignUp
                        ? context.tr('already_have_account')
                        : context.tr('no_account_sign_up'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Google sign-in
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
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
                      child: Divider(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                AuthButton(
                  onPressed: isLoading ? null : _handleGoogleSignIn,
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

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
      ),
      prefixIcon: Icon(
        icon,
        color: Colors.white.withValues(alpha: 0.5),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }
}
