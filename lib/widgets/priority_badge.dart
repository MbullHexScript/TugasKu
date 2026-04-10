import 'package:flutter/material.dart';

class PriorityBadge extends StatelessWidget {
  final String prioritas;

  const PriorityBadge({super.key, required this.prioritas});

  Color get _color {
    switch (prioritas) {
      case 'tinggi':
        return const Color(0xFFDC2626);
      case 'sedang':
        return const Color(0xFFF59E0B);
      case 'rendah':
        return const Color(0xFF059669);
      default:
        return Colors.grey;
    }
  }

  String get _label {
    switch (prioritas) {
      case 'tinggi':
        return '🔴 Tinggi';
      case 'sedang':
        return '🟡 Sedang';
      case 'rendah':
        return '🟢 Rendah';
      default:
        return prioritas;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
