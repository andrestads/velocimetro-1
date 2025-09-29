import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:velocimetro/main.dart';

void main() {
  testWidgets('Velocimetro app builds without errors', (WidgetTester tester) async {
    // Constrói o app
    await tester.pumpWidget(const MyApp());
    
    // Verifica se existe pelo menos um widget MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Verifica se não há erros de construção
    expect(tester.takeException(), isNull);
  });
}
