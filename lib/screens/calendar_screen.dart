import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedMonth;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  void _prevMonth() => setState(() {
        _focusedMonth =
            DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      });

  void _nextMonth() => setState(() {
        _focusedMonth =
            DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      });

  static const _dayLabels = [
    'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'
  ];

  String _monthYearLabel(DateTime dt) {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${bulan[dt.month - 1]} ${dt.year}';
  }

  String _bulanLabel(int month) {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return bulan[month - 1];
  }

  String _formatJam(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final tasksOnSelected = _selectedDay != null
            ? provider.tugasUntukTanggal(_selectedDay!)
            : <Task>[];

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          floatingActionButton: FloatingActionButton(
            heroTag: 'fab_calendar',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final ok = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const TaskFormScreen()),
              );
              if (!mounted) return;
              if (ok == true) {
                provider.reload();
                messenger.showSnackBar(
                  const SnackBar(
                      content: Text('Tugas berhasil disimpan')),
                );
              }
            },
            backgroundColor: cs.primary,
            child:
                const Icon(Icons.add_rounded, color: Colors.white),
          ),
          body: CustomScrollView(
            slivers: [
              // ── AppBar — tanpa icon notifikasi ──
              SliverAppBar(
                pinned: false,
                floating: true,
                backgroundColor:
                    Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Kalender Deadline',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(16, 4, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Calendar Card ──
                    Container(
                      padding:
                          const EdgeInsets.fromLTRB(12, 16, 12, 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? cs.surfaceContainerHighest
                            : cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: cs.outlineVariant
                              .withOpacity(isDark ? 0.20 : 0.55),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _NavBtn(
                                icon: Icons.chevron_left_rounded,
                                onTap: _prevMonth,
                                isDark: isDark,
                                cs: cs,
                              ),
                              Expanded(
                                child: Text(
                                  _monthYearLabel(_focusedMonth),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                              _NavBtn(
                                icon: Icons.chevron_right_rounded,
                                onTap: _nextMonth,
                                isDark: isDark,
                                cs: cs,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: List.generate(7, (i) {
                              final isSun = i == 6;
                              return Expanded(
                                child: Center(
                                  child: Text(
                                    _dayLabels[i],
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: isSun
                                          ? const Color(0xFFDC2626)
                                          : cs.onSurface
                                              .withOpacity(0.45),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          _buildCalendarGrid(provider, cs, isDark),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Text(
                          _selectedDay != null
                              ? 'Tugas ${_selectedDay!.day} ${_bulanLabel(_selectedDay!.month)}'
                              : 'Pilih tanggal',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (tasksOnSelected.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: cs.primary
                                  .withOpacity(isDark ? 0.18 : 0.10),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: cs.outlineVariant.withOpacity(
                                    isDark ? 0.20 : 0.55),
                              ),
                            ),
                            child: Text(
                              '${tasksOnSelected.length} Tugas',
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (tasksOnSelected.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_available_outlined,
                                size: 52,
                                color: cs.onSurface.withOpacity(0.2),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Tidak ada tugas pada hari ini',
                                style: TextStyle(
                                  color:
                                      cs.onSurface.withOpacity(0.35),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...tasksOnSelected.map((task) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: 10),
                            child: _CalendarTaskTile(
                              task: task,
                              formatJam: _formatJam,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TaskDetailScreen(task: task),
                                ),
                              ),
                            ),
                          )),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarGrid(
      TaskProvider provider, ColorScheme cs, bool isDark) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startOffset = (firstDayOfMonth.weekday - 1) % 7;
    final prevMonthDays =
        DateTime(_focusedMonth.year, _focusedMonth.month, 0).day;
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNum = cellIndex - startOffset + 1;

              if (dayNum < 1) {
                final prevDay =
                    prevMonthDays - (startOffset - cellIndex - 1);
                return _CalendarCell(
                    label: '$prevDay',
                    isOverflow: true,
                    isSunday: col == 6,
                    cs: cs,
                    isDark: isDark);
              }
              if (dayNum > daysInMonth) {
                final nextDay = dayNum - daysInMonth;
                return _CalendarCell(
                    label: '$nextDay',
                    isOverflow: true,
                    isSunday: col == 6,
                    cs: cs,
                    isDark: isDark);
              }

              final date = DateTime(
                  _focusedMonth.year, _focusedMonth.month, dayNum);
              final isToday = date == today;
              final isSelected = _selectedDay != null &&
                  date.year == _selectedDay!.year &&
                  date.month == _selectedDay!.month &&
                  date.day == _selectedDay!.day;
              final tasks = provider.tugasUntukTanggal(date);
              final hasTasks = tasks.isNotEmpty;

              Color dotColor = cs.primary;
              if (hasTasks) {
                final hasTerlambat = tasks.any((t) => t.isTerlambat);
                final hasUrgent =
                    tasks.any((t) => t.sisaHari <= 1 && !t.isSelesai);
                final allDone = tasks.every((t) => t.isSelesai);
                if (hasTerlambat) {
                  dotColor = const Color(0xFFDC2626);
                } else if (hasUrgent) {
                  dotColor = const Color(0xFFEA580C);
                } else if (allDone) {
                  dotColor = const Color(0xFF059669);
                } else {
                  dotColor = cs.secondary;
                }
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDay = date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 52,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cs.primary
                          : isToday
                              ? cs.primary.withOpacity(0.14)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isToday && !isSelected
                          ? Border.all(
                              color: cs.primary.withOpacity(0.5))
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNum',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isToday || isSelected
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : col == 6
                                    ? const Color(0xFFDC2626)
                                    : cs.onSurface,
                          ),
                        ),
                        if (hasTasks)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                for (int d = 0;
                                    d < tasks.length.clamp(1, 3);
                                    d++)
                                  Container(
                                    width: 5,
                                    height: 5,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 1),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : dotColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final ColorScheme cs;
  const _NavBtn(
      {required this.icon,
      required this.onTap,
      required this.isDark,
      required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark
              ? cs.surfaceContainerHigh
              : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                cs.outlineVariant.withOpacity(isDark ? 0.20 : 0.55),
          ),
        ),
        child: Icon(icon,
            color: cs.onSurface.withOpacity(0.7), size: 22),
      ),
    );
  }
}

class _CalendarCell extends StatelessWidget {
  final String label;
  final bool isOverflow;
  final bool isSunday;
  final ColorScheme cs;
  final bool isDark;
  const _CalendarCell(
      {required this.label,
      required this.isOverflow,
      required this.isSunday,
      required this.cs,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 52,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurface.withOpacity(0.22),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarTaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final String Function(DateTime) formatJam;
  const _CalendarTaskTile(
      {required this.task,
      required this.onTap,
      required this.formatJam});

  Color _barColor() {
    if (task.isSelesai) return const Color(0xFF006C4B);
    if (task.isTerlambat) return const Color(0xFFDC2626);
    switch (task.prioritas) {
      case 'tinggi':
        return const Color(0xFFDC2626);
      case 'sedang':
        return const Color(0xFF004445);
      default:
        return const Color(0xFF006C4B);
    }
  }

  String _priorityLabel() {
    switch (task.prioritas) {
      case 'tinggi':
        return 'URGENT';
      case 'sedang':
        return 'MEDIUM';
      default:
        return 'LOW';
    }
  }

  Color _priorityBg() {
    switch (task.prioritas) {
      case 'tinggi':
        return const Color(0xFFFFE4E6);
      case 'sedang':
        return const Color(0xFFE7EEFF);
      default:
        return const Color(0xFFE8FFF3);
    }
  }

  Color _priorityText() {
    switch (task.prioritas) {
      case 'tinggi':
        return const Color(0xFFDC2626);
      case 'sedang':
        return const Color(0xFF004445);
      default:
        return const Color(0xFF006C4B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = _barColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? cs.surfaceContainerHighest
              : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                cs.outlineVariant.withOpacity(isDark ? 0.20 : 0.55),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 90,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? barColor.withOpacity(0.2)
                                : _priorityBg(),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _priorityLabel(),
                            style: TextStyle(
                              color: isDark
                                  ? barColor
                                  : _priorityText(),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.access_time_rounded,
                            size: 13,
                            color: cs.onSurface.withOpacity(0.4)),
                        const SizedBox(width: 4),
                        Text(
                          formatJam(task.deadline),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      task.namaTugas,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: cs.onSurface,
                        decoration: task.isSelesai
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.catatan.isNotEmpty
                          ? task.catatan
                          : task.mataKuliah,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withOpacity(0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
