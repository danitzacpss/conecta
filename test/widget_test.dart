import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:conecta_app/app/app.dart';

void main() {
  testWidgets('ConectaApp renders router', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ConectaApp()));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
