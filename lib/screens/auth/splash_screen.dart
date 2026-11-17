import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final auth = context.read<AuthProvider>();
        if (auth.isLoggedIn && auth.role != null) {
          switch (auth.role!) {
            case UserRole.admin:
              Navigator.pushReplacementNamed(context, '/admin');
              break;
            case UserRole.seller:
              Navigator.pushReplacementNamed(context, '/seller');
              break;
            case UserRole.customer:
              Navigator.pushReplacementNamed(context, '/customer');
              break;
          }
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: AppColors.accentLight,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'BookNest',
                  style: GoogleFonts.poppins(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Literary Haven',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFD5CEBF),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: AppColors.accentLight,
                    strokeWidth: 2.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
