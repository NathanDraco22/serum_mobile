import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:serum_mobile/src/cubits/report_cubit/report_mobile_state.dart';
import 'package:serum_mobile/src/modules/report/widgets/date_range_selector.dart';

void main() {
  group('Report Locale & DateRangeSelector Tests', () {
    test('initializeDateFormatting carga el locale "es" y formatea correctamente', () async {
      await initializeDateFormatting('es', null);
      final date = DateTime(2026, 10, 22);
      final fmt = DateFormat('dd MMM yyyy', 'es');
      final result = fmt.format(date);

      expect(result.toLowerCase(), contains('oct'));
      expect(result, contains('2026'));
    });

    testWidgets('DateRangeSelector renderiza correctamente sin arrojar LocaleDataException', (WidgetTester tester) async {
      await initializeDateFormatting('es', null);
      final start = DateTime(2026, 10, 1).millisecondsSinceEpoch;
      final end = DateTime(2026, 10, 22).millisecondsSinceEpoch;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeSelector(
              activeFilter: ReportTimeFilter.today,
              startDate: start,
              endDate: end,
              onFilterSelected: (_) {},
              onCustomRangeSelected: (start, end) {},
            ),
          ),
        ),
      );

      expect(find.text('Periodo de Análisis'), findsOneWidget);
      expect(find.text('Hoy'), findsOneWidget);
      expect(find.text('Esta Semana'), findsOneWidget);
      expect(find.text('Este Mes'), findsOneWidget);
      expect(find.text('Personalizado'), findsOneWidget);
    });

    testWidgets('DateRangeSelector usa fallback seguro si el formateo no tiene locale cargado', (WidgetTester tester) async {
      final start = DateTime(2026, 5, 10).millisecondsSinceEpoch;
      final end = DateTime(2026, 5, 20).millisecondsSinceEpoch;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeSelector(
              activeFilter: ReportTimeFilter.custom,
              startDate: start,
              endDate: end,
              onFilterSelected: (_) {},
              onCustomRangeSelected: (start, end) {},
            ),
          ),
        ),
      );

      expect(find.byType(DateRangeSelector), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
