import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasi_cuaca/main.dart';

void main() {
  testWidgets('weather app renders search controls', (WidgetTester tester) async {
    await tester.pumpWidget(const CuacaApp());

    expect(find.text('Aplikasi Cuaca'), findsOneWidget);
    expect(find.text('Nama kota'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });
}
