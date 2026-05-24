import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import '../services/hive_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnim = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;
    _navigateNext();
  }

  void _navigateNext() {
    // Selalu langsung ke HomeScreen — onboarding dilewati
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: cs.primary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ──────────────────────────────────────
          Image.asset(
            'assets/images/screen.png',
            fit: BoxFit.cover,
            width: size.width,
            height: size.height,
            errorBuilder: (_, error, __) {
              debugPrint('Splash image error: $error');
              // Fallback gradient kalau gambar tidak ditemukan
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primary,
                      const Color(0xFF0D5D5E),
                      const Color(0xFF006C4B),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Dark overlay supaya teks terbaca ─────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.55),
                ],
              ),
            ),
          ),

          // ── Konten tengah ─────────────────────────────────────────
          SafeArea(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnim,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnim.value),
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: child,
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon badge
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.20),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.assignment_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // App name
                  const Text(
                    'TUGASKU',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tagline
                  Text(
                    'Kelola Deadline, Kendalikan Waktu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.85),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Loading indicator + versi (bawah layar) ──────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: AnimatedBuilder(
                animation: _fadeAnim,
                builder: (_, child) =>
                    FadeTransition(opacity: _fadeAnim, child: child!),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.70),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'v1.2.0',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.50),
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
