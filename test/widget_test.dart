import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tugasku/widgets/empty_state.dart';

void main() {
  testWidgets('EmptyState shows title and subtitle', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EmptyState(
          ikon: Icons.inbox_outlined,
          judul: 'Tidak ada data',
          subjudul: 'Silakan tambahkan item terlebih dahulu.',
        ),
      ),
    );

    expect(find.text('Tidak ada data'), findsOneWidget);
    expect(find.text('Silakan tambahkan item terlebih dahulu.'), findsOneWidget);
  });
}
