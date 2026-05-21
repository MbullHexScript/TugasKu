import 'package:flutter/material.dart';

class PriorityBadge extends StatelessWidget {
  final String prioritas;

  const PriorityBadge({super.key, required this.prioritas});

  Color get _color {
    switch (prioritas) {
      case 'tinggi':
        return const Color(0xFFDC2626);
      case 'sedang':
        return const Color(0xFF3F4948);
      case 'rendah':
        return const Color(0xFF006C4B);
      default:
        return Colors.grey;
    }
  }

  String get _label {
    switch (prioritas) {
      case 'tinggi':
        return 'TINGGI';
      case 'sedang':
        return 'SEDANG';
      case 'rendah':
        return 'RENDAH';
      default:
        return prioritas.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _color.withOpacity(0.22)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
