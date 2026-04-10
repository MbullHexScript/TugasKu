import 'package:flutter/material.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _OnboardSlide(
      icon: Icons.school_rounded,
      emoji: '🎓',
      title: 'Selamat Datang\ndi TugasKu!',
      subtitle:
          'Kelola semua tugas kuliah dalam satu tempat.\nTidak ada lagi tugas yang terlupakan.',
      gradientColors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
    ),
    _OnboardSlide(
      icon: Icons.alarm_on_rounded,
      emoji: '⏰',
      title: 'Notifikasi\nDeadline Otomatis',
      subtitle:
          'Dapatkan pengingat H-2, H-1, dan hari-H.\nSelalu tepat waktu dan tidak ketinggalan.',
      gradientColors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    ),
    _OnboardSlide(
      icon: Icons.bar_chart_rounded,
      emoji: '📊',
      title: 'Pantau Progress\n& Kalender',
      subtitle:
          'Lihat statistik penyelesaian tugas dan\njadwal deadline di kalender bulanan.',
      gradientColors: [Color(0xFF059669), Color(0xFF0EA5E9)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    Navigator.pushReplacement(
      context,
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
    final slide = _slides[_currentPage];

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background that animates with page
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  slide.gradientColors[0].withOpacity(0.15),
                  slide.gradientColors[1].withOpacity(0.05),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: _finish,
                      child: const Text('Lewati',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _slides.length,
                    itemBuilder: (ctx, i) =>
                        _SlideContent(slide: _slides[i]),
                  ),
                ),
                // Bottom controls
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                  child: Column(
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin:
                                const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == i ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: _currentPage == i
                                  ? LinearGradient(
                                      colors:
                                          _slides[_currentPage].gradientColors)
                                  : null,
                              color: _currentPage == i
                                  ? null
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Action buttons
                      Row(
                        children: [
                          if (_currentPage > 0) ...[
                            OutlinedButton(
                              onPressed: () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOutCubic,
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Icon(Icons.arrow_back),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors:
                                        _slides[_currentPage].gradientColors),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: _slides[_currentPage]
                                        .gradientColors[0]
                                        .withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _next,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                ),
                                child: Text(
                                  _currentPage < _slides.length - 1
                                      ? 'Lanjut'
                                      : 'Mulai Sekarang! 🚀',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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

class _SlideContent extends StatefulWidget {
  final _OnboardSlide slide;
  const _SlideContent({required this.slide});

  @override
  State<_SlideContent> createState() => _SlideContentState();
}

class _SlideContentState extends State<_SlideContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeScale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeScale =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _fadeScale,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.slide.gradientColors[0].withOpacity(0.2),
                    widget.slide.gradientColors[1].withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.slide.gradientColors[0].withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(widget.slide.emoji,
                    style: const TextStyle(fontSize: 72)),
              ),
            ),
          ),
          const SizedBox(height: 48),
          FadeTransition(
            opacity: _fadeScale,
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: widget.slide.gradientColors,
              ).createShader(bounds),
              child: Text(
                widget.slide.title,
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: _fadeScale,
            child: Text(
              widget.slide.subtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade500,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardSlide {
  final IconData icon;
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;

  const _OnboardSlide({
    required this.icon,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
  });
}
