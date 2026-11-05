import 'package:flutter_test/flutter_test.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/src/tools/calculators/kpi_calculators.dart';

void main() {
  group('KpiCalculators Tests', () {
    final sampleOrders = [
      OrderInDb(
        id: 'ord_1',
        patientId: 'p_1',
        branchId: 'b_1',
        totalPrice: 15000,
        paidAmount: 15000,
        status: 'completed',
        isBlocked: false,
        createdAt: 1000,
        items: [
          OrderItem(labTestId: 't1', name: 'Glucosa', salePriceApplied: 7500),
          OrderItem(labTestId: 't2', name: 'Urea', salePriceApplied: 7500),
        ],
      ),
      OrderInDb(
        id: 'ord_2',
        patientId: 'p_2',
        branchId: 'b_1',
        totalPrice: 25000,
        paidAmount: 20000,
        status: 'pending',
        isBlocked: true,
        createdAt: 2000,
        items: [
          OrderItem(labTestId: 't3', name: 'Biometría', salePriceApplied: 25000),
        ],
      ),
    ];

    final sampleShifts = [
      CashShiftInDb(
        id: 'sh_1',
        userId: 'u_1',
        branchId: 'b_1',
        initialBalance: 5000,
        cashBalance: 10000,
        totalBalance: 15000,
        openedAt: 1000,
        createdAt: 1000,
        closedAt: null, // Open
      ),
      CashShiftInDb(
        id: 'sh_2',
        userId: 'u_1',
        branchId: 'b_1',
        status: 'CLOSED',
        initialBalance: 5000,
        cashBalance: 8000,
        totalBalance: 13000,
        openedAt: 1000,
        createdAt: 1000,
        closedAt: 2000,
        declaredCash: 7500,
        difference: -500, // Discrepancy
      ),
      CashShiftInDb(
        id: 'sh_3',
        userId: 'u_2',
        branchId: 'b_2',
        status: 'CLOSED',
        initialBalance: 5000,
        cashBalance: 8000,
        totalBalance: 13000,
        openedAt: 1000,
        createdAt: 1000,
        closedAt: 2000,
        declaredCash: 8000,
        difference: 0, // Squared
      ),
    ];

    test('calculateTotalSalesCents suma correctamente los totales de las órdenes', () {
      final total = KpiCalculators.calculateTotalSalesCents(sampleOrders);
      expect(total, 40000); // 15000 + 25000
    });

    test('calculateTotalTestsCount cuenta la cantidad total de ítems de órdenes', () {
      final testsCount = KpiCalculators.calculateTotalTestsCount(sampleOrders);
      expect(testsCount, 3); // 2 + 1
    });

    test('filterBlockedOrders filtra solo órdenes con isBlocked == true', () {
      final blocked = KpiCalculators.filterBlockedOrders(sampleOrders);
      expect(blocked.length, 1);
      expect(blocked.first.id, 'ord_2');
    });

    test('countActiveShifts cuenta los turnos que no han sido cerrados', () {
      final active = KpiCalculators.countActiveShifts(sampleShifts);
      expect(active, 1);
    });

    test('countDiscrepancyShifts cuenta turnos cerrados con descuadre', () {
      final discrepancies = KpiCalculators.countDiscrepancyShifts(sampleShifts);
      expect(discrepancies, 1);
    });

    test('calculateTotalShiftsRevenueCents suma los fondos totales de turnos', () {
      final revenue = KpiCalculators.calculateTotalShiftsRevenueCents(sampleShifts);
      expect(revenue, 41000); // 15000 + 13000 + 13000
    });
  });
}
