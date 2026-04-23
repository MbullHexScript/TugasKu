import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import '../services/hive_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _taglineFadeAnim;

  @override
  void initState() {
    super.initState();

    // Make status bar transparent
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // Background fade + scale animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    // Logo/title scale-in animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Tagline slide-up animation
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _taglineFadeAnim =
        CurvedAnimation(parent: _slideController, curve: Curves.easeOut);

    _startAnimations();
  }

  void _startAnimations() async {
    // Stagger the animations
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _slideController.forward();

    // Navigate after splash duration
    await Future.delayed(const Duration(milliseconds: 1800));
    _navigateNext();
  }

  void _navigateNext() {
    if (!mounted) return;
    final isFirstLaunch = HiveService.getIsFirstLaunch();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
            isFirstLaunch ? const OnboardingScreen() : const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background Image ──────────────────────────────────────
          FadeTransition(
            opacity: _fadeAnim,
            child: Image.asset(
              'assets/images/splash_background.jpg',
              fit: BoxFit.cover,
              // Fallback: if image not found, show gradient background
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF4F3FF),
                      Color(0xFFEDE9FE),
                      Color(0xFFDDD6FE),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── White overlay for brightness control ──────────────────
          FadeTransition(
            opacity: _fadeAnim,
            child: Container(
              color: Colors.white.withOpacity(0.55),
            ),
          ),

          // ── Content ───────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon + Title
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    children: [
                      // Icon badge
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withOpacity(0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.assignment_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // App name
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'TUGAS',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E1040),
                                letterSpacing: 2,
                              ),
                            ),
                            TextSpan(
                              text: 'KU',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E1040),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Tagline – slides up
                SlideTransition(
                  position: _slideAnim,
                  child: FadeTransition(
                    opacity: _taglineFadeAnim,
                    child: const Text(
                      'Kelola Deadline, Kendalikan Waktu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4A4060),
                        letterSpacing: 0.3,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom branding ───────────────────────────────────────
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _taglineFadeAnim,
              child: Column(
                children: [
                  // Animated dots loader
                  _DotsLoader(color: const Color(0xFF7C3AED)),
                  const SizedBox(height: 16),
                  Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF4A4060).withOpacity(0.6),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated dots loading indicator ────────────────────────────────────────────
class _DotsLoader extends StatefulWidget {
  final Color color;
  const _DotsLoader({required this.color});

  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final double t = (_ctrl.value - i * 0.2).clamp(0.0, 1.0);
            final double scale = 0.5 + 0.5 * (1 - (2 * t - 1).abs());
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8 * scale,
              height: 8 * scale,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.4 + 0.6 * scale),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
