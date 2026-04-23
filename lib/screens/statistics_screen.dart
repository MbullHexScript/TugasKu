import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/focus_provider.dart';
import '../providers/mata_kuliah_provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer3<TaskProvider, MataKuliahProvider, FocusProvider>(
      builder: (context, taskProv, mkProv, focusProv, _) {
        final sedangJalan = taskProv.semuaTugas
            .where((t) => !t.isSelesai && t.status == 'proses')
            .length;

        final totalJam = focusProv.totalHours;
        final streak = focusProv.streakDays;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F0D13) : const Color(0xFFF4F3FF),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: false,
                floating: true,
                backgroundColor:
                    isDark ? const Color(0xFF0F0D13) : const Color(0xFFF4F3FF),
                elevation: 0,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.menu_rounded, color: cs.primary, size: 26),
                      const SizedBox(width: 14),
                      Text(
                        'Statistik',
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      const Spacer(),
                      Stack(
                        children: [
                          Icon(Icons.notifications_outlined, color: cs.primary, size: 26),
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
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              value: taskProv.jumlahSelesai,
                              label: 'SELESAI',
                              icon: Icons.check_circle_rounded,
                              color: const Color(0xFF7C3AED),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricCard(
                              value: sedangJalan,
                              label: 'SEDANG JALAN',
                              icon: Icons.timer_rounded,
                              color: const Color(0xFF0EA5E9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              value: totalJam,
                              label: 'TOTAL JAM',
                              icon: Icons.history_rounded,
                              color: const Color(0xFFEA580C),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricCard(
                              value: streak,
                              label: 'STREAK HARI',
                              icon: Icons.bolt_rounded,
                              color: const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      _SectionCard(
                        title: 'Laju Penyelesaian',
                        subtitle: 'Performa mingguan Anda',
                        child: _CompletionRing(progress: taskProv.progressPenyelesaian),
                      ),
                      const SizedBox(height: 14),

                      _SectionCard(
                        title: 'Distribusi Materi',
                        subtitle: 'Berdasarkan kategori tugas',
                        child: _DistributionDonut(
                          data: taskProv.tugasPerMataKuliah,
                          mkProv: mkProv,
                        ),
                      ),
                      const SizedBox(height: 14),

                      _SectionCard(
                        title: 'Tingkat Prioritas',
                        subtitle: null,
                        child: _PriorityBars(tasks: taskProv.semuaTugas),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1826) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: isDark ? const Color(0xFFEDE9FE) : const Color(0xFF1E1040),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: cs.onSurface.withOpacity(0.55),
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1826) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? const Color(0xFFEDE9FE) : const Color(0xFF1E1040),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withOpacity(0.5),
              ),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _CompletionRing extends StatelessWidget {
  final double progress;
  const _CompletionRing({required this.progress});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = (progress.clamp(0.0, 1.0) * 100).round();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: CustomPaint(
            painter: _CircularProgressPainter(
              progress: progress.clamp(0.0, 1.0),
              color: cs.primary,
              backgroundColor: isDark ? const Color(0xFF2D2640) : const Color(0xFFEDE9FE),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$pct%',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: isDark ? const Color(0xFFEDE9FE) : const Color(0xFF1E1040),
                    ),
                  ),
                  Text(
                    'TARGET',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: cs.onSurface.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(label: 'Tercapai', color: cs.primary),
            const SizedBox(width: 26),
            _LegendDot(
              label: 'Tersisa',
              color: isDark ? const Color(0xFF2D2640) : const Color(0xFFEDE9FE),
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cs.onSurface.withOpacity(0.55),
          ),
        ),
      ],
    );
  }
}

class _DistributionDonut extends StatelessWidget {
  final Map<String, int> data;
  final MataKuliahProvider mkProv;
  const _DistributionDonut({required this.data, required this.mkProv});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final entries = data.entries
        .where((e) => e.key.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = entries.fold<int>(0, (sum, e) => sum + e.value);
    final values = entries.map((e) => e.value.toDouble()).toList();
    final colors = entries
        .map((e) => Color(mkProv.getWarna(e.key)))
        .toList(growable: false);

    return Column(
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(220, 220),
                painter: _DonutChartPainter(values: values, colors: colors),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: isDark ? const Color(0xFFEDE9FE) : const Color(0xFF1E1040),
                    ),
                  ),
                  Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: cs.onSurface.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (int i = 0; i < entries.length; i++)
              _DistChip(
                label: entries[i].key,
                percent: total == 0 ? 0 : ((entries[i].value / total) * 100).round(),
                color: colors[i],
                isDark: isDark,
              ),
            if (entries.isEmpty)
              Text(
                'Belum ada data tugas',
                style: TextStyle(color: cs.onSurface.withOpacity(0.5)),
              ),
          ],
        ),
      ],
    );
  }
}

class _DistChip extends StatelessWidget {
  final String label;
  final int percent;
  final Color color;
  final bool isDark;
  const _DistChip({required this.label, required this.percent, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final short = label.length > 14 ? '${label.substring(0, 14)}…' : label;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.20) : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$short $percent%',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PriorityBars extends StatelessWidget {
  final List<Task> tasks;
  const _PriorityBars({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tinggi = tasks.where((t) => t.prioritas == 'tinggi').length;
    final sedang = tasks.where((t) => t.prioritas == 'sedang').length;
    final rendah = tasks.where((t) => t.prioritas == 'rendah').length;
    final total = tasks.length;

    final rows = [
      _PriorityRowData('Sangat Penting', tinggi, const Color(0xFFDC2626)),
      _PriorityRowData('Sedang', sedang, const Color(0xFFEA580C)),
      _PriorityRowData('Rendah', rendah, const Color(0xFF0EA5E9)),
    ];

    return Column(
      children: [
        for (final row in rows) ...[
          Row(
            children: [
              Container(width: 7, height: 7, decoration: BoxDecoration(color: row.color, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  row.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withOpacity(0.8),
                  ),
                ),
              ),
              Text(
                '${row.count} Tugas',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface.withOpacity(0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : (row.count / total),
              minHeight: 10,
              backgroundColor: cs.outline.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(row.color),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _PriorityRowData {
  final String label;
  final int count;
  final Color color;
  const _PriorityRowData(this.label, this.count, this.color);
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  const _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    const strokeWidth = 10.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter old) => old.progress != progress;
}

class _DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  const _DonutChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 28.0;
    const gapAngle = 0.05;
    final hasGap = values.length > 1;

    var startAngle = -math.pi / 2;

    for (int i = 0; i < values.length; i++) {
      final rawSweep = (values[i] / total) * (2 * math.pi);
      final sweepAngle = math.max(0.0, rawSweep - (hasGap ? gapAngle : 0.0));
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += rawSweep;
    }
  }

  @override
  bool shouldRepaint(_DonutChartPainter old) => old.values != values;
}
