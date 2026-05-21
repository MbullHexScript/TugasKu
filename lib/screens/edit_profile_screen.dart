import 'package:flutter/material.dart';

import '../services/hive_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _programCtrl;
  late int _semester;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: HiveService.getProfileName());
    _programCtrl = TextEditingController(text: HiveService.getProfileProgram());
    _semester = HiveService.getProfileSemester();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _programCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final form = _formKey.currentState;
    if (form == null) return;
    FocusScope.of(context).unfocus();
    if (!form.validate()) return;

    setState(() => _saving = true);
    try {
      await HiveService.setProfile(
        name: _nameCtrl.text.trim(),
        program: _programCtrl.text.trim(),
        semester: _semester,
      );
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: cs.primary),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          'Edit Profil',
          style: TextStyle(
            color: cs.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_outlined, color: cs.primary),
            tooltip: 'Notifikasi',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: cs.primary.withOpacity(0.20),
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: cs.primary.withOpacity(0.10),
                              child: Icon(Icons.person_rounded,
                                  color: cs.primary, size: 54),
                            ),
                          ),
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.10),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.edit_rounded,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'UNGGAH FOTO BARU',
                        style: TextStyle(
                          color: cs.secondary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.8,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                const _FieldLabel('Nama Lengkap'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan nama lengkap...',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Nama wajib diisi';
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                const _FieldLabel('Program Studi'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _programCtrl,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Teknik Informatika',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Program studi wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),
                const _FieldLabel('Semester'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final sem in const [5, 6, 7, 8]) ...[
                      Expanded(
                        child: _SemesterChip(
                          value: sem,
                          selected: _semester == sem,
                          onTap: () => setState(() => _semester = sem),
                        ),
                      ),
                      if (sem != 8) const SizedBox(width: 10),
                    ],
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed:
                        _saving ? null : () => Navigator.pop(context, false),
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark
                          ? cs.surfaceContainerHigh
                          : cs.surfaceContainerLow,
                      foregroundColor: cs.onSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: cs.onSurface.withOpacity(0.55),
        fontWeight: FontWeight.w900,
        letterSpacing: 1.6,
        fontSize: 12,
      ),
    );
  }
}

class _SemesterChip extends StatelessWidget {
  final int value;
  final bool selected;
  final VoidCallback onTap;
  const _SemesterChip({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? cs.secondaryContainer : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? cs.secondary.withOpacity(0.35)
                : cs.outlineVariant.withOpacity(0.70),
            width: selected ? 1.6 : 1.2,
          ),
        ),
        child: Text(
          '$value',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: selected ? cs.onSecondaryContainer : cs.onSurface,
          ),
        ),
      ),
    );
  }
}
