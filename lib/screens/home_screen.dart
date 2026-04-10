import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import 'task_form_screen.dart';
import 'task_list_screen.dart';
import 'calendar_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

// ─────────────────────────────── Root Shell ──────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  static const _navItems = [
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'HOME'),
    _NavItem(Icons.list_alt_outlined, Icons.list_alt_rounded, 'TASKS'),
    _NavItem(Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'CALENDAR'),
    _NavItem(Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'STATS'),
    _NavItem(Icons.settings_outlined, Icons.settings_rounded, 'SETTINGS'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> halaman = [
      const _DashboardTab(),
      const TaskListScreen(),
      const CalendarScreen(),
      const StatisticsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: halaman),
      floatingActionButton: _tabIndex == 1
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TaskFormScreen()),
              ),
              child: const Icon(Icons.add_rounded),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF150F20) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (i) {
                final item = _navItems[i];
                final selected = _tabIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _tabIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: selected
                        ? BoxDecoration(
                            color: cs.primary.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(14),
                          )
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selected ? item.activeIcon : item.icon,
                          size: 22,
                          color: selected
                              ? cs.primary
                              : cs.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: selected
                                ? cs.primary
                                : cs.onSurface.withOpacity(0.4),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

// ─────────────────────────────── Dashboard Tab ───────────────────────────────

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  String _greeting() {
    final jam = DateTime.now().hour;
    if (jam < 10) return 'Selamat Pagi ☀️';
    if (jam < 14) return 'Selamat Siang 🌤️';
    if (jam < 18) return 'Selamat Sore 🌅';
    return 'Selamat Malam 🌙';
  }

  String _motivasi(int jam) {
    if (jam < 10) return 'Ayo selesaikan\nmimpimu.';
    if (jam < 14) return 'Tetap fokus,\nkamu bisa!';
    if (jam < 18) return 'Sedikit lagi,\njangan menyerah!';
    return 'Istirahat sebentar,\nlanjut besok!';
  }

  static String formatJam(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m WIB';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final jam = DateTime.now().hour;

    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final pct = (provider.progressPenyelesaian * 100).round();
        final motivasi = _motivasi(jam);

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF0F0D13) : const Color(0xFFF4F3FF),
          body: CustomScrollView(
            slivers: [
              // ── AppBar ──
              SliverAppBar(
                pinned: false,
                floating: true,
                backgroundColor: isDark
                    ? const Color(0xFF0F0D13)
                    : const Color(0xFFF4F3FF),
                elevation: 0,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.menu_rounded,
                          color: cs.primary, size: 26),
                      const SizedBox(width: 12),
                      Text(
                        'TugasKu',
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const Spacer(),
                      Stack(
                        children: [
                          Icon(Icons.notifications_outlined,
                              color: cs.primary, size: 26),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFDC2626),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: cs.primary.withOpacity(0.15),
                        child: Icon(Icons.person_rounded,
                            size: 18, color: cs.primary),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Greeting Card ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E1535)
                            : const Color(0xFFEEEBFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            motivasi,
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFFEDE9FE)
                                  : const Color(0xFF1E1040),
                              fontWeight: FontWeight.w800,
                              fontSize: 26,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Stats Row ──
                    Row(
                      children: [
                        _StatCard(
                          label: 'AKTIF',
                          nilai: provider.jumlahAktif,
                          ikon: Icons.pending_actions_rounded,
                          iconColor: cs.primary,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'SELESAI',
                          nilai: provider.jumlahSelesai,
                          ikon: Icons.check_circle_outline_rounded,
                          iconColor: const Color(0xFF059669),
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'MENDESAK',
                          nilai: provider.jumlahMendekatiDeadline,
                          ikon: Icons.priority_high_rounded,
                          iconColor: const Color(0xFFDC2626),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Progress Card ──
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1C1826)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Progres Mingguan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: isDark
                                          ? const Color(0xFFEDE9FE)
                                          : const Color(0xFF1E1040),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    pct >= 80
                                        ? 'Hampir mencapai target!'
                                        : pct >= 50
                                            ? 'Terus semangat!'
                                            : 'Ayo mulai kerjakan!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: cs.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: cs.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$pct%',
                                  style: TextStyle(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: provider.progressPenyelesaian,
                              minHeight: 9,
                              backgroundColor:
                                  cs.primary.withOpacity(0.10),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  cs.primary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Deadline Hari Ini ──
                    Row(
                      children: [
                        Text(
                          'Deadline Hari Ini',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: isDark
                                ? const Color(0xFFEDE9FE)
                                : const Color(0xFF1E1040),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (provider.tugasHariIni.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: cs.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${provider.tugasHariIni.length}',
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Lihat Semua',
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (provider.tugasHariIni.isEmpty)
                      _EmptyHint(
                        pesan: 'Tidak ada deadline hari ini 🎉',
                        warna: const Color(0xFF059669),
                      )
                    else
                      ...provider.tugasHariIni.map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _TugasHariIniCard(task: t),
                          )),

                    const SizedBox(height: 20),

                    // ── Focus session banner ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF7C3AED),
                            Color(0xFF6D28D9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Mulai Sesi Fokus?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Singkirkan distraksi selama 25 menit.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.nightlight_round,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add,
                                      size: 14, color: Color(0xFF7C3AED)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Stat Card ──────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final int nilai;
  final IconData ikon;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.nilai,
    required this.ikon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1826) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(ikon, color: iconColor, size: 24),
            const SizedBox(height: 6),
            Text(
              '$nilai',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tugas Hari Ini Card ────────────────────────────────────────────────────────

class _TugasHariIniCard extends StatelessWidget {
  final Task task;
  const _TugasHariIniCard({required this.task});

  Color _leftBarColor() {
    switch (task.prioritas) {
      case 'tinggi':
        return const Color(0xFFDC2626);
      case 'sedang':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF059669);
    }
  }

  String _formatJam(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m WIB';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = _leftBarColor();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1826) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // left color bar
          Container(
            width: 4,
            height: 72,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.namaTugas,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark
                          ? const Color(0xFFEDE9FE)
                          : const Color(0xFF1E1040),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    task.mataKuliah.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface.withOpacity(0.4),
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hari ini!',
                  style: TextStyle(
                    color: barColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatJam(task.deadline),
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.45),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
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

// ── Empty Hint ─────────────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  final String pesan;
  final Color warna;
  const _EmptyHint({required this.pesan, required this.warna});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: warna.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: warna.withOpacity(0.2)),
      ),
      child: Text(pesan,
          style: TextStyle(color: warna, fontWeight: FontWeight.w600)),
    );
  }
}
