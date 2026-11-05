import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/src/cubits/dashboard_cubit/dashboard_mobile_cubit.dart';

class MockOrdersRepository extends Fake implements OrdersRepository {
  List<OrderInDb> ordersToReturn = [];
  final _eventController = StreamController<RepoEvent<OrderInDb>>.broadcast();

  @override
  Stream<RepoEvent<OrderInDb>> get eventStream => _eventController.stream;

  @override
  Future<List<OrderInDb>> getAllOrders({OrderQueryParams? queryParams}) async {
    return ordersToReturn;
  }

  void emitEvent(RepoEvent<OrderInDb> event) {
    _eventController.add(event);
  }

  void dispose() {
    _eventController.close();
  }
}

class MockCashShiftsRepository extends Fake implements CashShiftsRepository {
  List<CashShiftInDb> shiftsToReturn = [];
  final _eventController = StreamController<RepoEvent<CashShiftInDb>>.broadcast();

  @override
  Stream<RepoEvent<CashShiftInDb>> get eventStream => _eventController.stream;

  @override
  Future<List<CashShiftInDb>> getAllCashShifts({String? branchId, String? status, String? userId}) async {
    return shiftsToReturn;
  }

  void emitEvent(RepoEvent<CashShiftInDb> event) {
    _eventController.add(event);
  }

  void dispose() {
    _eventController.close();
  }
}

void main() {
  group('DashboardMobileCubit Tests', () {
    late MockOrdersRepository mockOrdersRepo;
    late MockCashShiftsRepository mockShiftsRepo;

    final sampleOrders = [
      OrderInDb(
        id: 'o1',
        patientId: 'p1',
        branchId: 'b1',
        totalPrice: 20000,
        paidAmount: 20000,
        status: 'completed',
        isBlocked: false,
        createdAt: 1000,
        items: [
          OrderItem(labTestId: 't1', name: 'Glucosa', salePriceApplied: 20000),
        ],
      ),
      OrderInDb(
        id: 'o2',
        patientId: 'p2',
        branchId: 'b1',
        totalPrice: 30000,
        paidAmount: 10000,
        status: 'pending',
        isBlocked: true,
        createdAt: 2000,
        items: [
          OrderItem(labTestId: 't2', name: 'Perfil 1', salePriceApplied: 15000),
          OrderItem(labTestId: 't3', name: 'Perfil 2', salePriceApplied: 15000),
        ],
      ),
    ];

    final sampleShifts = [
      CashShiftInDb(
        id: 's1',
        userId: 'u1',
        branchId: 'b1',
        initialBalance: 5000,
        cashBalance: 15000,
        totalBalance: 20000,
        openedAt: 1000,
        createdAt: 1000,
        closedAt: null,
      ),
    ];

    setUp(() {
      mockOrdersRepo = MockOrdersRepository();
      mockShiftsRepo = MockCashShiftsRepository();
      mockOrdersRepo.ordersToReturn = sampleOrders;
      mockShiftsRepo.shiftsToReturn = sampleShifts;
    });

    tearDown(() {
      mockOrdersRepo.dispose();
      mockShiftsRepo.dispose();
    });

    test('DashboardMobileCubit inicializa y carga órdenes y turnos calculando métricas', () async {
      final cubit = DashboardMobileCubit(
        ordersRepository: mockOrdersRepo,
        cashShiftsRepository: mockShiftsRepo,
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          predicate<DashboardMobileState>((s) => s.status == DashboardMobileStatus.loading),
          predicate<DashboardMobileState>((s) {
            return s.status == DashboardMobileStatus.success &&
                s.ordersCount == 2 &&
                s.totalSalesCents == 50000 &&
                s.testsCount == 3 &&
                s.activeShiftsCount == 1 &&
                s.blockedOrdersCount == 1;
          }),
        ]),
      );

      await cubit.loadData();
      await expectation;
      await cubit.close();
    });

    test('DashboardMobileCubit recarga automáticamente al emitirse evento en OrdersRepository', () async {
      final cubit = DashboardMobileCubit(
        ordersRepository: mockOrdersRepo,
        cashShiftsRepository: mockShiftsRepo,
      );

      // Esperar carga inicial
      await Future.delayed(const Duration(milliseconds: 50));

      // Actualizar datos del mock
      mockOrdersRepo.ordersToReturn = [sampleOrders.first];

      // Disparar evento reactivo
      mockOrdersRepo.emitEvent(RepoItemCreated<OrderInDb>(sampleOrders.first));

      await expectLater(
        cubit.stream,
        emits(
          predicate<DashboardMobileState>((s) => s.ordersCount == 1 && s.totalSalesCents == 20000),
        ),
      );

      await cubit.close();
    });
  });
}
