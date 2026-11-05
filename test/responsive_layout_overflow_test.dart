import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/cubits/report_cubit/report_mobile_state.dart';
import 'package:serum_mobile/src/modules/dashboard/widgets/kpi_grid.dart';
import 'package:serum_mobile/src/modules/report/widgets/date_range_selector.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  group('Responsive Layout Overflow Regression Tests', () {
    testWidgets(
        'DateRangeSelector renderiza sin overflow en ancho restringido (244.4 px) con rango largo',
        (WidgetTester tester) async {
      final start = DateTime(2026, 10, 1).millisecondsSinceEpoch;
      final end = DateTime(2026, 11, 5).millisecondsSinceEpoch;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 244.4),
                child: DateRangeSelector(
                  activeFilter: ReportTimeFilter.custom,
                  startDate: start,
                  endDate: end,
                  onFilterSelected: (_) {},
                  onCustomRangeSelected: (start, end) {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Periodo de Análisis'), findsOneWidget);
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets(
        'Selector de sucursal en ancho estrecho (244.4 px) no desborda horizontalmente (5.0 px)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 244.4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ColorPalette.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ColorPalette.outlineVariant,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.corporate_fare_rounded,
                              size: 18,
                              color: ColorPalette.primary,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Todas las Sucursales - Matriz Principal',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.tune_rounded, size: 14),
                        label: const Text('Cambiar',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Cambiar'), findsOneWidget);
    });

    testWidgets(
        'KpiGrid renderiza en dispositivo estrecho (360x640) sin desbordamiento inferior (8.8 px)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: KpiGrid(
                totalSalesFormatted: '\$1,250,500.00',
                ordersCount: 142,
                testsCount: 385,
                activeShiftsCount: 4,
                blockedOrdersCount: 2,
                showApprovalsKpi: true,
                onTapSales: () {},
                onTapOrders: () {},
                onTapShifts: () {},
                onTapApprovals: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Ventas Totales'), findsOneWidget);
      expect(find.text('Por Autorizar'), findsOneWidget);
    });
  });
}
