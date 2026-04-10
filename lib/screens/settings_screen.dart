import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mata_kuliah_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: Consumer<MataKuliahProvider>(
        builder: (context, mkProv, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Mata Kuliah Section ──
              _SectionLabel(label: 'Mata Kuliah'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outline.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16))),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.school_rounded,
                            color: cs.primary, size: 20),
                      ),
                      title: const Text('Daftar Mata Kuliah',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(
                          '${mkProv.daftarMataKuliah.length} mata kuliah',
                          style: const TextStyle(fontSize: 12)),
                      trailing: FilledButton.tonal(
                        onPressed: () =>
                            _dialogTambahMK(context, mkProv),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_rounded, size: 16),
                            SizedBox(width: 4),
                            Text('Tambah', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    if (mkProv.daftarMataKuliah.isNotEmpty)
                      Divider(height: 1, color: cs.outline.withOpacity(0.15)),
                    ...mkProv.daftarMataKuliah.asMap().entries.map((entry) {
                      final i = entry.key;
                      final mk = entry.value;
                      final isLast =
                          i == mkProv.daftarMataKuliah.length - 1;
                      return Column(
                        children: [
                          ListTile(
                            shape: isLast
                                ? const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16)))
                                : null,
                            leading: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Color(mk.warna),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            title: Text(mk.nama,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            trailing: IconButton(
                              icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red,
                                  size: 20),
                              onPressed: () =>
                                  _konfirmasiHapusMK(context, mkProv, mk),
                            ),
                          ),
                          if (!isLast)
                            Divider(
                                height: 1,
                                indent: 60,
                                color: cs.outline.withOpacity(0.15)),
                        ],
                      );
                    }),
                    if (mkProv.daftarMataKuliah.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Belum ada mata kuliah. Tap Tambah untuk menambahkan.',
                          style: TextStyle(
                              color: cs.onSurface.withOpacity(0.4),
                              fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── About Section ──
              _SectionLabel(label: 'Tentang Aplikasi'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outline.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    _AboutTile(
                        icon: Icons.info_outline_rounded,
                        label: 'Versi Aplikasi',
                        value: '2.0.0',
                        isFirst: true),
                    Divider(
                        height: 1,
                        indent: 60,
                        color: cs.outline.withOpacity(0.15)),
                    _AboutTile(
                        icon: Icons.code_rounded,
                        label: 'Developer',
                        value: 'NaufalNyaa'),
                    Divider(
                        height: 1,
                        indent: 60,
                        color: cs.outline.withOpacity(0.15)),
                    _AboutTile(
                        icon: Icons.palette_outlined,
                        label: 'Tema',
                        value: 'Midnight Scholar',
                        isLast: true),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  void _dialogTambahMK(BuildContext context, MataKuliahProvider provider) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tambah Mata Kuliah',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Nama Mata Kuliah',
            prefixIcon: Icon(Icons.school_outlined),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) {
            if (ctrl.text.trim().isNotEmpty) {
              provider.tambahMataKuliah(ctrl.text.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                provider.tambahMataKuliah(ctrl.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _konfirmasiHapusMK(BuildContext context,
      MataKuliahProvider provider, mk) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Mata Kuliah?'),
        content: Text('Yakin ingin menghapus "${mk.nama}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              provider.hapusMataKuliah(mk);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
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
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;

  const _AboutTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    BorderRadius? shape;
    if (isFirst && isLast) {
      shape = BorderRadius.circular(16);
    } else if (isFirst) {
      shape = const BorderRadius.only(
          topLeft: Radius.circular(16), topRight: Radius.circular(16));
    } else if (isLast) {
      shape = const BorderRadius.only(
          bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16));
    }

    return ListTile(
      shape: shape != null ? RoundedRectangleBorder(borderRadius: shape) : null,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: cs.primary, size: 18),
      ),
      title: Text(label),
      trailing: Text(
        value,
        style: TextStyle(
            color: cs.onSurface.withOpacity(0.5), fontSize: 13),
      ),
    );
  }
}
