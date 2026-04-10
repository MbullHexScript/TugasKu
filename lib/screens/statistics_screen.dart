import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/mata_kuliah_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TaskProvider, MataKuliahProvider>(
      builder: (context, taskProv, mkProv, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Statistik')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            children: [
              // ── Summary Cards ──
              _SectionTitle(judul: 'Ringkasan'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Total Tugas',
                      nilai: taskProv.semuaTugas.length,
                      ikon: Icons.assignment_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Terlambat',
                      nilai: taskProv.jumlahTerlambat,
                      ikon: Icons.running_with_errors_rounded,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Selesai',
                      nilai: taskProv.jumlahSelesai,
                      ikon: Icons.check_circle_rounded,
                      color: const Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Mendesak',
                      nilai: taskProv.jumlahMendekatiDeadline,
                      ikon: Icons.warning_amber_rounded,
                      color: const Color(0xFFEA580C),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Completion Rate ──
              _SectionTitle(judul: 'Tingkat Penyelesaian'),
              const SizedBox(height: 8),
              _CompletionRateCard(provider: taskProv),

              const SizedBox(height: 24),

              // ── Donut Chart by Subject ──
              _SectionTitle(judul: 'Distribusi per Mata Kuliah'),
              const SizedBox(height: 8),
              _DonutChartCard(
                taskPerMatKul: taskProv.tugasPerMataKuliah,
                mkProvider: mkProv,
              ),

              const SizedBox(height: 24),

              // ── Priority Distribution ──
              _SectionTitle(judul: 'Distribusi Prioritas'),
              const SizedBox(height: 8),
              _PriorityBarCard(tasks: taskProv.semuaTugas),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String judul;
  const _SectionTitle({required this.judul});

  @override
  Widget build(BuildContext context) {
    return Text(judul,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w800));
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int nilai;
  final IconData ikon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.nilai,
    required this.ikon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(ikon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$nilai',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: color.withOpacity(0.7),
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletionRateCard extends StatelessWidget {
  final TaskProvider provider;
  const _CompletionRateCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = provider.progressPenyelesaian;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: _CircularProgressPainter(
                progress: pct,
                color: cs.primary,
                backgroundColor: cs.outline.withOpacity(0.15),
              ),
              child: Center(
                child: Text(
                  '${(pct * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: cs.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LegendItem(
                    color: const Color(0xFF059669),
                    label: 'Selesai',
                    count: provider.jumlahSelesai),
                const SizedBox(height: 8),
                _LegendItem(
                    color: cs.primary,
                    label: 'Aktif',
                    count: provider.jumlahAktif),
                const SizedBox(height: 8),
                _LegendItem(
                    color: const Color(0xFFDC2626),
                    label: 'Terlambat',
                    count: provider.jumlahTerlambat),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  const _LegendItem(
      {required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text('$count',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: color, fontSize: 13)),
      ],
    );
  }
}

class _DonutChartCard extends StatelessWidget {
  final Map<String, int> taskPerMatKul;
  final MataKuliahProvider mkProvider;

  const _DonutChartCard({
    required this.taskPerMatKul,
    required this.mkProvider,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (taskPerMatKul.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline.withOpacity(0.15)),
        ),
        child: Center(
          child: Text('Belum ada data tugas',
              style: TextStyle(color: cs.onSurface.withOpacity(0.4))),
        ),
      );
    }

    final total = taskPerMatKul.values.fold(0, (a, b) => a + b);
    final entries = taskPerMatKul.entries.toList();
    final colors = entries.map((e) {
      final warna = mkProvider.getWarna(e.key);
      return Color(warna);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: CustomPaint(
              painter: _DonutChartPainter(
                values: entries.map((e) => e.value.toDouble()).toList(),
                colors: colors,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$total',
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900)),
                    Text('tugas',
                        style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withOpacity(0.5))),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(entries.length, (i) {
              final pct =
                  (entries[i].value / total * 100).toStringAsFixed(0);
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colors[i].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors[i].withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: colors[i], shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(
                      '${entries[i].key} ($pct%)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors[i],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PriorityBarCard extends StatelessWidget {
  final List tasks;
  const _PriorityBarCard({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tinggi = tasks.where((t) => t.prioritas == 'tinggi').length;
    final sedang = tasks.where((t) => t.prioritas == 'sedang').length;
    final rendah = tasks.where((t) => t.prioritas == 'rendah').length;
    final total = tasks.length;

    final data = [
      _BarData('Tinggi', tinggi, const Color(0xFFDC2626)),
      _BarData('Sedang', sedang, const Color(0xFFF59E0B)),
      _BarData('Rendah', rendah, const Color(0xFF059669)),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.15)),
      ),
      child: Column(
        children: data
            .map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PriorityBar(data: d, total: total),
                ))
            .toList(),
      ),
    );
  }
}

class _BarData {
  final String label;
  final int count;
  final Color color;
  const _BarData(this.label, this.count, this.color);
}

class _PriorityBar extends StatelessWidget {
  final _BarData data;
  final int total;
  const _PriorityBar({required this.data, required this.total});

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : data.count / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: data.color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(data.label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            const Spacer(),
            Text('${data.count} tugas',
                style: TextStyle(
                    fontSize: 12,
                    color: data.color,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 10,
            backgroundColor:
                Theme.of(context).colorScheme.outline.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(data.color),
          ),
        ),
      ],
    );
  }
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
  bool shouldRepaint(_CircularProgressPainter old) =>
      old.progress != progress;
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

    var startAngle = -math.pi / 2;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle =
          (values[i] / total) * (2 * math.pi) - gapAngle;
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
      startAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(_DonutChartPainter old) => old.values != values;
}
