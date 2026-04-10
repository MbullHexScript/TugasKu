import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData ikon;
  final String judul;
  final String subjudul;

  const EmptyState({
    super.key,
    required this.ikon,
    required this.judul,
    required this.subjudul,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(ikon,
                  size: 48, color: cs.primary.withOpacity(0.4)),
            ),
            const SizedBox(height: 20),
            Text(
              judul,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subjudul,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurface.withOpacity(0.4),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
