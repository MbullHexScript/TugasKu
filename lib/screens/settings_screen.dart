import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/focus_provider.dart';
import '../providers/mata_kuliah_provider.dart';
import '../providers/task_provider.dart';
import '../services/hive_service.dart';
import 'splash_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer2<MataKuliahProvider, TaskProvider>(
      builder: (context, mkProv, taskProv, _) {
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
                        'Pengaturan',
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // Profile header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: cs.primary.withOpacity(0.35), width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: cs.primary.withOpacity(0.12),
                              child: Icon(Icons.person_rounded, color: cs.primary, size: 26),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mahasiswa',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: isDark ? const Color(0xFFEDE9FE) : const Color(0xFF1E1040),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Teknik Informatika • Semester 4',
                                  style: TextStyle(
                                    color: cs.onSurface.withOpacity(0.55),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),
                      const _SectionLabel(label: 'Akademik'),
                      const SizedBox(height: 10),

                      _CardShell(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: cs.primary.withOpacity(0.10),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.menu_book_rounded, color: cs.primary, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Mata Kuliah',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: isDark ? const Color(0xFFEDE9FE) : const Color(0xFF1E1040),
                                      ),
                                    ),
                                  ),
                                  FilledButton(
                                    onPressed: () => _dialogTambahMK(context, mkProv),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: cs.primary,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                      elevation: 0,
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add_rounded, size: 16, color: Colors.white),
                                        SizedBox(width: 6),
                                        Text(
                                          'Tambah',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (mkProv.daftarMataKuliah.isEmpty)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                                child: Text(
                                  'Belum ada mata kuliah. Tambahkan dulu ya.',
                                  style: TextStyle(color: cs.onSurface.withOpacity(0.55)),
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  children: [
                                    for (final mk in mkProv.daftarMataKuliah) ...[
                                      _MataKuliahTile(
                                        nama: mk.nama,
                                        warna: Color(mk.warna),
                                        subtitle: '${taskProv.semuaTugas.where((t) => t.mataKuliah == mk.nama).length} tugas',
                                        onDelete: () => _konfirmasiHapusMK(context, mkProv, mk),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),
                      const _SectionLabel(label: 'Sistem & Informasi'),
                      const SizedBox(height: 10),

                      _CardShell(
                        child: Column(
                          children: const [
                            _InfoTile(
                              icon: Icons.info_outline_rounded,
                              label: 'Versi Aplikasi',
                              trailingText: 'v1.0.0',
                              isFirst: true,
                            ),
                            _InfoDivider(),
                            _InfoTile(
                              icon: Icons.code_rounded,
                              label: 'Developer',
                              trailingText: 'TugasKu Creative Team',
                            ),
                            _InfoDivider(),
                            _InfoTile(
                              icon: Icons.palette_outlined,
                              label: 'Tema Visual',
                              trailingText: 'Academic Purple',
                              showChevron: true,
                            ),
                            _InfoDivider(),
                            _InfoTile(
                              icon: Icons.shield_outlined,
                              label: 'Privasi & Keamanan',
                              trailingText: '',
                              showChevron: true,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 26),
                      Center(
                        child: TextButton(
                          onPressed: () => _logout(context),
                          child: const Text(
                            'Keluar Akun',
                            style: TextStyle(
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'DIBUAT DENGAN ♥ UNTUK MAHASISWA INDONESIA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface.withOpacity(0.35),
                            letterSpacing: 1.0,
                          ),
                        ),
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

  void _dialogTambahMK(BuildContext context, MataKuliahProvider provider) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tambah Mata Kuliah', style: TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Nama Mata Kuliah',
            prefixIcon: Icon(Icons.school_outlined),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) async {
            if (ctrl.text.trim().isEmpty) return;
            await provider.tambahMataKuliah(ctrl.text.trim());
            if (context.mounted) Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              await provider.tambahMataKuliah(ctrl.text.trim());
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _konfirmasiHapusMK(BuildContext context, MataKuliahProvider provider, mk) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Mata Kuliah?'),
        content: Text('Yakin ingin menghapus "${mk.nama}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              await provider.hapusMataKuliah(mk);
              if (context.mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar Akun?'),
        content: const Text('Ini akan menghapus semua data lokal (tugas & mata kuliah).'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await HiveService.resetAllData();
    if (!context.mounted) return;
    context.read<TaskProvider>().reload();
    context.read<MataKuliahProvider>().reload();
    context.read<FocusProvider>().reload();
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SplashScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      ),
      (_) => false,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Container(
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
        border: Border.all(color: cs.outline.withOpacity(isDark ? 0.25 : 0.12)),
      ),
      child: child,
    );
  }
}

class _MataKuliahTile extends StatelessWidget {
  final String nama;
  final String subtitle;
  final Color warna;
  final VoidCallback onDelete;

  const _MataKuliahTile({
    required this.nama,
    required this.subtitle,
    required this.warna,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF150F20) : const Color(0xFFF4F3FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: warna, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: isDark ? const Color(0xFFEDE9FE) : const Color(0xFF1E1040),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurface.withOpacity(0.55),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded, color: cs.onSurface.withOpacity(0.45), size: 20),
            tooltip: 'Hapus',
          ),
        ],
      ),
    );
  }
}

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Divider(height: 1, indent: 56, color: cs.outline.withOpacity(0.12));
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String trailingText;
  final bool showChevron;
  final bool isFirst;
  final bool isLast;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.trailingText,
    this.showChevron = false,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    BorderRadius? radius;
    if (isFirst && isLast) {
      radius = BorderRadius.circular(20);
    } else if (isFirst) {
      radius = const BorderRadius.vertical(top: Radius.circular(20));
    } else if (isLast) {
      radius = const BorderRadius.vertical(bottom: Radius.circular(20));
    }

    return ListTile(
      dense: true,
      shape: radius == null ? null : RoundedRectangleBorder(borderRadius: radius),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: cs.primary, size: 18),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: showChevron
          ? Icon(Icons.chevron_right_rounded, color: cs.onSurface.withOpacity(0.35))
          : Text(
              trailingText,
              style: TextStyle(
                color: cs.onSurface.withOpacity(0.55),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
      onTap: showChevron ? () {} : null,
    );
  }
}
