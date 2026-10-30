import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import 'package:serum_mobile/src/cubits/approvals_cubit/approvals_cubit.dart';
import 'package:serum_mobile/src/modules/approvals/widgets/approval_order_card.dart';
import 'package:serum_mobile/src/modules/approvals/widgets/price_discrepancy_table.dart';

class MockOrdersRepo extends Fake implements OrdersRepository {
  List<OrderInDb> orders = [];
  String? lastApprovedId;
  String? lastDeletedId;
  OrderApproveRequest? lastApproveRequest;
  final _controller = StreamController<RepoEvent<OrderInDb>>.broadcast();

  @override
  Stream<RepoEvent<OrderInDb>> get eventStream => _controller.stream;

  @override
  Future<List<OrderInDb>> getAllOrders({OrderQueryParams? queryParams}) async {
    return orders;
  }

  @override
  Future<OrderInDb> approveOrder(String orderId, OrderApproveRequest approveRequest) async {
    lastApprovedId = orderId;
    lastApproveRequest = approveRequest;
    final order = orders.firstWhere((o) => o.id == orderId);
    return order;
  }

  @override
  Future<OrderInDb?> deleteOrderById(String orderId) async {
    lastDeletedId = orderId;
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      return orders.removeAt(index);
    }
    return null;
  }
}

class MockAppSessionCubit extends Fake implements AppSessionCubit {
  final UserInDb user;
  MockAppSessionCubit(this.user);

  @override
  UserInDb? get currentUser => user;

  @override
  AppSessionState get state => AppSessionState(currentUser: user);
}

void main() {
  final sampleUser = UserInDb(
    id: 'sup-1',
    name: 'Dr. Supervisor',
    username: 'supervisor',
    email: 'sup@serum.com',
    role: 'Admin',
    accessLevel: 5,
    branches: ['branch-1'],
    isActive: true,
    createdAt: 1730000000000,
  );

  final sampleOrderWithDiscounts = OrderInDb(
    id: 'ord-12345678',
    patientId: 'pat-1',
    branchId: 'branch-1',
    createdAt: 1730000000000,
    items: [
      OrderItem(
        labTestId: 'test-1',
        name: 'Perfil Bioquímico Completo',
        originalPrice: 10000, // $100.00
        salePriceApplied: 10000,
      ),
      OrderItem(
        labTestId: 'test-2',
        name: 'Biometría Hemática',
        originalPrice: 5000, // $50.00
        salePriceApplied: 4000, // $40.00 (descuento manual en ítem)
      ),
    ],
    services: [
      OrderService(id: 'srv-1', name: 'Toma de muestra a domicilio', price: 1500), // $15.00
    ],
    discounts: [
      OrderDiscount(
        id: 'disc-1',
        description: 'Tercera Edad (15%)',
        type: 'percentage',
        value: 15.0,
        appliedAmount: 2325, // $23.25
      ),
    ],
    totalPrice: 13175, // $131.75
    paidAmount: 0,
    isBlocked: true,
    approval: OrderApproval(
      requiresApproval: true,
      isApproved: false,
      reason: 'Descuento del 15% requiere autorización',
    ),
    patientInfo: PatientInfo(name: 'Carlos Mendoza'),
  );

  group('PriceDiscrepancyTable tests', () {
    testWidgets('renders item catalog discrepancies, services and order discounts correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PriceDiscrepancyTable(order: sampleOrderWithDiscounts),
            ),
          ),
        ),
      );

      // 1. Debe mostrar los exámenes
      expect(find.text('Perfil Bioquímico Completo'), findsOneWidget);
      expect(find.text('Biometría Hemática'), findsOneWidget);

      // 2. Debe mostrar los servicios adicionales
      expect(find.text('Toma de muestra a domicilio'), findsOneWidget);

      // 3. Debe mostrar los descuentos de la orden
      expect(find.text('Descuentos en la Orden (1)'), findsOneWidget);
      expect(find.text('Tercera Edad (15%)'), findsOneWidget);
      expect(find.text('15%'), findsOneWidget);

      // 4. Debe mostrar el total a cobrar
      expect(find.text('Total a Cobrar:'), findsOneWidget);
      expect(find.textContaining('131.75'), findsOneWidget);
    });
  });

  group('ApprovalOrderCard tests', () {
    testWidgets('renders both Reject and Approve buttons with correct actions', (tester) async {
      bool rejectCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ApprovalOrderCard(
                order: sampleOrderWithDiscounts,
                isApproving: false,
                isRejecting: false,
                onApprove: (_) {},
                onReject: () => rejectCalled = true,
              ),
            ),
          ),
        ),
      );

      // Verifica presencia del paciente, folio y botones
      expect(find.text('Carlos Mendoza'), findsOneWidget);
      expect(find.text('FOL-ORD-1234'), findsOneWidget);
      expect(find.text('Rechazar'), findsOneWidget);
      expect(find.text('Aprobar Orden'), findsOneWidget);

      // Al pulsar rechazar se abre el diálogo de confirmación
      await tester.tap(find.text('Rechazar'));
      await tester.pumpAndSettle();

      expect(find.text('¿Estás seguro de que deseas rechazar y descartar la orden FOL-ORD-1234?\n\nEsta orden retenida se eliminará y la ventanilla deberá registrarla nuevamente si corresponde.'), findsOneWidget);
      
      // Confirmar en el diálogo
      final confirmButtons = find.widgetWithText(ElevatedButton, 'Rechazar');
      expect(confirmButtons, findsOneWidget);
      await tester.tap(confirmButtons);
      await tester.pumpAndSettle();

      expect(rejectCalled, isTrue);
    });
  });

  group('ApprovalsCubit tests', () {
    test('approveOrder marks order as approved and calls repository', () async {
      final repo = MockOrdersRepo()..orders = [sampleOrderWithDiscounts];
      final session = MockAppSessionCubit(sampleUser);
      final cubit = ApprovalsCubit(ordersRepository: repo, appSessionCubit: session);

      await cubit.loadBlockedOrders();
      expect(cubit.state.blockedOrders.length, 1);

      final success = await cubit.approveOrder('ord-12345678', reason: 'Aprobado por dirección');
      expect(success, isTrue);
      expect(repo.lastApprovedId, 'ord-12345678');
      expect(repo.lastApproveRequest?.reason, 'Aprobado por dirección');
      expect(cubit.state.blockedOrders.isEmpty, isTrue);

      await cubit.close();
    });

    test('rejectOrder deletes order and removes it from state', () async {
      final repo = MockOrdersRepo()..orders = [sampleOrderWithDiscounts];
      final session = MockAppSessionCubit(sampleUser);
      final cubit = ApprovalsCubit(ordersRepository: repo, appSessionCubit: session);

      await cubit.loadBlockedOrders();
      expect(cubit.state.blockedOrders.length, 1);

      final success = await cubit.rejectOrder('ord-12345678');
      expect(success, isTrue);
      expect(repo.lastDeletedId, 'ord-12345678');
      expect(cubit.state.blockedOrders.isEmpty, isTrue);
      expect(cubit.state.successMessage, 'Orden rechazada y descartada del sistema.');

      await cubit.close();
    });
  });
}
