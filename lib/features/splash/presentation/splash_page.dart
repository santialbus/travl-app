import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/route_constants.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    context.go(user != null ? RouteConstants.home : RouteConstants.auth);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF060D1A),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Spacer(flex: 3),

              // Logo
              Image.asset(
                'assets/logo/logotravl.png',
                width: size.width * 0.38,
                height: size.width * 0.38,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 32),

              // Nombre
              const Text(
                'Travl',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 10),

              // Tagline
              Text(
                'PLAN IT. SHARE IT. LIVE IT.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 11,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(flex: 3),

              // Loading indicator
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.3),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.07),

            ],
          ),
        ),
      ),
    );
  }
}
