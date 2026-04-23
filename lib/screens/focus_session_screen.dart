import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/focus_provider.dart';

class FocusSessionScreen extends StatefulWidget {
  final Duration duration;
  const FocusSessionScreen({super.key, this.duration = const Duration(minutes: 25)});

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen> {
  Timer? _timer;
  late final Duration _initial;
  late Duration _remaining;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _initial = widget.duration;
    _remaining = _initial;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (_running) return;
    setState(() => _running = true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining.inSeconds <= 1) {
        setState(() => _remaining = Duration.zero);
        _finish(auto: true);
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  void _pause() {
    _timer?.cancel();
    if (mounted) setState(() => _running = false);
  }

  void _reset() {
    _pause();
    setState(() => _remaining = _initial);
  }

  String _mmss(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _finish({required bool auto}) async {
    _pause();
    final elapsed = _initial - _remaining;
    final minutes = elapsed.inMinutes;
    final shouldClose = auto || minutes > 0;
    if (minutes > 0) {
      await context.read<FocusProvider>().addSessionMinutes(minutes);
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(auto ? 'Sesi fokus selesai!' : 'Sesi fokus disimpan'),
          content: Text(
            minutes <= 0
                ? 'Coba jalankan sesi minimal 1 menit agar tercatat.'
                : 'Keren! Kamu fokus selama $minutes menit.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(backgroundColor: cs.primary),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (shouldClose && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _initial.inSeconds == 0
        ? 0.0
        : 1 - (_remaining.inSeconds / _initial.inSeconds);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0D13) : const Color(0xFFF4F3FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: cs.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Sesi Fokus',
          style: TextStyle(
            color: cs.primary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.nightlight_round, color: Colors.white, size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Singkirkan distraksi, fokus dulu.',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 210,
                      height: 210,
                      child: CircularProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        strokeWidth: 12,
                        backgroundColor: isDark
                            ? const Color(0xFF2D2640)
                            : cs.primary.withOpacity(0.10),
                        valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _mmss(_remaining),
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: isDark ? const Color(0xFFEDE9FE) : const Color(0xFF1E1040),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _running ? 'Sedang berjalan' : 'Siap mulai',
                          style: TextStyle(
                            color: cs.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _remaining == _initial && !_running ? null : _reset,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _running ? _pause : _start,
                    icon: Icon(_running ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white),
                    label: Text(
                      _running ? 'Pause' : 'Mulai',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _finish(auto: false),
                child: Text('Selesai & Simpan', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
