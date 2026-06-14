import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../models/notification_log_model.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../services/hive_service.dart';
import 'task_list_screen.dart';
import 'calendar_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';
import 'focus_session_screen.dart';
import 'task_detail_screen.dart';
import 'edit_profile_screen.dart';
import 'notification_center_sheet.dart';
import 'dart:io';

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
    _NavItem(Icons.calendar_month_outlined, Icons.calendar_month_rounded,
        'CALENDAR'),
    _NavItem(Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'STATS'),
    _NavItem(Icons.settings_outlined, Icons.settings_rounded, 'SETTINGS'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> halaman = [
      _DashboardTab(
        onLihatSemua: () => setState(() => _tabIndex = 1),
        onMulaiFokus: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FocusSessionScreen()),
        ),
      ),
      const TaskListScreen(),
      const CalendarScreen(),
      const StatisticsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: halaman[_tabIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF150F20) : cs.surfaceContainerLowest,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: selected
                        ? BoxDecoration(
                            color: cs.primary.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(18),
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
  final VoidCallback onLihatSemua;
  final VoidCallback onMulaiFokus;

  const _DashboardTab({
    required this.onLihatSemua,
    required this.onMulaiFokus,
  });

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

  void _bukaNotificationCenter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationCenterSheet(),
    );
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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          floatingActionButton: FloatingActionButton(
            heroTag: 'fab_dashboard',
            onPressed: onMulaiFokus,
            backgroundColor: cs.primary,
            child: const Icon(Icons.nightlight_round, color: Colors.white),
          ),
          body: CustomScrollView(
            slivers: [
              // ── AppBar ──
              SliverAppBar(
                pinned: false,
                floating: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
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
                      // ── Icon Notifikasi dengan Badge Dinamis ──
                      ValueListenableBuilder<Box<NotificationLog>>(
                        valueListenable:
                            HiveService.getNotifLogBox().listenable(),
                        builder: (context, box, _) {
                          final now = DateTime.now();
                          final adaBelumDibaca = box.values.any(
                            (log) =>
                                !log.sudahDibaca &&
                                log.waktu.isBefore(now),
                          );
                          return GestureDetector(
                            onTap: () =>
                                _bukaNotificationCenter(context),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.notifications_outlined,
                                    color: cs.primary,
                                    size: 26,
                                  ),
                                ),
                                if (adaBelumDibaca)
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: Container(
                                      width: 9,
                                      height: 9,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFDC2626),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const EditProfileScreen()),
                        ),
                        child: ValueListenableBuilder(
                          valueListenable:
                              HiveService.getSettingsBox().listenable(
                            keys: const ['profilePhoto'],
                          ),
                          builder: (context, _, __) {
                            final photoPath =
                                HiveService.getProfilePhoto();
                            final hasPhoto = photoPath != null &&
                                photoPath.isNotEmpty;
                            return CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  cs.primary.withOpacity(0.12),
                              backgroundImage: hasPhoto
                                  ? FileImage(File(photoPath))
                                  : null,
                              child: hasPhoto
                                  ? null
                                  : Icon(Icons.person_rounded,
                                      size: 18, color: cs.primary),
                            );
                          },
                        ),
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
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  cs.primary.withOpacity(0.22),
                                  cs.secondary.withOpacity(0.16),
                                ]
                              : [
                                  cs.primary.withOpacity(0.10),
                                  cs.secondary.withOpacity(0.10),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: cs.outlineVariant
                              .withOpacity(isDark ? 0.25 : 0.60),
                        ),
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
                              color: cs.onSurface,
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
                          iconColor: const Color(0xFF006C4B),
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
                            ? cs.surfaceContainerHighest
                            : cs.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: cs.outlineVariant
                              .withOpacity(isDark ? 0.20 : 0.55),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Progres Mingguan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: cs.onSurface,
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
                                      color:
                                          cs.onSurface.withOpacity(0.5),
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(cs.primary),
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
                            color: cs.onSurface,
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
                          onTap: onLihatSemua,
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
                        warna: const Color(0xFF006C4B),
                      )
                    else
                      ...provider.tugasHariIni.map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _TugasHariIniCard(
                              task: t,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TaskDetailScreen(task: t),
                                ),
                              ),
                            ),
                          )),

                    const SizedBox(height: 20),

                    // ── Focus session banner ──
                    GestureDetector(
                      onTap: onMulaiFokus,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF004445),
                              Color(0xFF0D5D5E),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
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
                          ],
                        ),
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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color:
              isDark ? cs.surfaceContainerHighest : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: cs.outlineVariant.withOpacity(isDark ? 0.20 : 0.55),
          ),
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
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.5),
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
  final VoidCallback onTap;
  const _TugasHariIniCard({required this.task, required this.onTap});

  Color _leftBarColor() {
    switch (task.prioritas) {
      case 'tinggi':
        return const Color(0xFFDC2626);
      case 'sedang':
        return const Color(0xFF004445);
      default:
        return const Color(0xFF006C4B);
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                        color: cs.onSurface,
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
