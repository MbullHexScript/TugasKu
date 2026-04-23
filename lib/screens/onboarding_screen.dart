import 'package:flutter/material.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = [
    _OnboardPageData(
      isLogo: true,
      title: 'TUGASKU',
      subtitle: 'Kelola Deadline, Kendalikan Waktu.',
    ),
    _OnboardPageData(
      isLogo: false,
      title: 'Atur Deadline',
      subtitle: 'Tambah tugas, atur prioritas, dan pantau jadwal dengan kalender.',
    ),
    _OnboardPageData(
      isLogo: false,
      title: 'Pantau Performa',
      subtitle: 'Lihat statistik penyelesaian dan fokus harianmu secara ringkas.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
      return;
    }
    _finish();
  }

  void _back() {
    if (_index <= 0) return;
    _controller.previousPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/splash_background.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
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
          Container(color: Colors.white.withOpacity(0.62)),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemCount: _pages.length,
                    itemBuilder: (_, i) => _OnboardPage(page: _pages[i], color: cs.primary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 6, 26, 26),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (i) {
                          final selected = _index == i;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: selected ? 34 : 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: selected ? cs.primary : const Color(0xFFD1D5DB),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _index < _pages.length - 1 ? 'Next Step' : 'Mulai',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _index == 0 ? null : _back,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPageData {
  final bool isLogo;
  final String title;
  final String subtitle;

  const _OnboardPageData({
    required this.isLogo,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardPage extends StatelessWidget {
  final _OnboardPageData page;
  final Color color;

  const _OnboardPage({required this.page, required this.color});

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF111827);
    const subtitleColor = Color(0xFF4A4060);

    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 20, 26, 20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (page.isLogo) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    page.title,
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(color: titleColor, width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notes_rounded, color: titleColor),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                ),
              ),
            ] else ...[
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: color,
                  size: 44,
                ),
              ),
              const SizedBox(height: 26),
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: titleColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
