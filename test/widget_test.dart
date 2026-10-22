import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/src/modules/activation/view/activation_screen.dart';

class MockServinRepository implements ServinRepository {
  @override
  Future<Servin> getActiveServin(
    String apiKey,
    String nickname, {
    String? originServerUrl,
  }) async {
    return Servin(
      name: 'Lab Test',
      nickname: nickname,
      url: 'http://localhost:8000',
      isActive: true,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('ActivationScreen renderiza correctamente los campos de enlace', (WidgetTester tester) async {
    final mockServinRepo = MockServinRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: RepositoryProvider<ServinRepository>.value(
          value: mockServinRepo,
          child: const ActivationScreen(),
        ),
      ),
    );

    expect(find.text('Activar Dispositivo'), findsOneWidget);
    expect(find.text('Alias del Negocio'), findsOneWidget);
    expect(find.text('Clave de Activación (API Key)'), findsOneWidget);
    expect(find.text('Vincular y Activar'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
