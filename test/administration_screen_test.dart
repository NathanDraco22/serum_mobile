import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import 'package:serum_mobile/src/modules/administration/view/administration_screen.dart';

class MockOrdersRepo extends Fake implements OrdersRepository {
  List<OrderInDb> orders = [];
  final _controller = StreamController<RepoEvent<OrderInDb>>.broadcast();

  @override
  Stream<RepoEvent<OrderInDb>> get eventStream => _controller.stream;

  @override
  Future<List<OrderInDb>> getAllOrders({OrderQueryParams? queryParams}) async {
    return orders;
  }
}

class MockReportsRepo extends Fake implements ReportsRepository {
  @override
  Future<FinancialReportResponse> getFinancialReport({
    required int startDate,
    required int endDate,
    String? branchId,
  }) async {
    return const FinancialReportResponse(
      startDate: 1000,
      endDate: 2000,
      summary: FinancialSummaryReport(
        totalBilled: 50000,
        totalCollected: 45000,
        ordersCount: 10,
      ),
    );
  }

  @override
  Future<LabTestsVolumeReportResponse> getLabTestsVolumeReport({
    required int startDate,
    required int endDate,
    String? branchId,
    String source = 'orders',
    int limit = 10,
  }) async {
    return const LabTestsVolumeReportResponse(
      startDate: 1000,
      endDate: 2000,
      summary: LabTestsVolumeSummary(totalTestsCount: 10, topTests: []),
    );
  }

  @override
  Future<ShiftsAuditReportResponse> getShiftsAuditReport({
    required int startDate,
    required int endDate,
    String? branchId,
    bool onlyDiscrepancies = false,
  }) async {
    return const ShiftsAuditReportResponse(
      startDate: 1000,
      endDate: 2000,
      summary: ShiftsAuditSummary(totalShifts: 2, totalDiscrepancies: 0),
    );
  }

  @override
  Future<TopDoctorsReportResponse> getTopDoctorsReport({
    required int startDate,
    required int endDate,
    String? branchId,
    int limit = 10,
  }) async {
    return const TopDoctorsReportResponse(
      startDate: 1000,
      endDate: 2000,
      summary: TopDoctorsSummary(totalOrders: 5, totalRevenue: 25000, topDoctors: []),
    );
  }

  @override
  Future<PendingBalancesReportResponse> getPendingBalancesReport({
    required int startDate,
    required int endDate,
    String? branchId,
  }) async {
    return const PendingBalancesReportResponse(
      startDate: 1000,
      endDate: 2000,
      summary: PendingBalancesSummary(totalPendingAmount: 12000, ordersCount: 3),
    );
  }
}

class MockAppSessionCubit extends Fake implements AppSessionCubit {
  final UserInDb user;
  final List<BranchInDb> branches;
  MockAppSessionCubit(this.user, this.branches);

  @override
  UserInDb? get currentUser => user;

  @override
  AppSessionState get state => AppSessionState(
        status: AppSessionStatus.authenticated,
        currentUser: user,
        branches: branches,
        currentBranch: branches.isNotEmpty ? branches.first : null,
      );

  @override
  Stream<AppSessionState> get stream => const Stream.empty();
}

void main() {
  final adminUser = UserInDb(
    id: 'admin_1',
    username: 'admin',
    name: 'Dra. Directora',
    role: 'Admin',
    accessLevel: 5,
    createdAt: 1000000,
  );

  final sampleBranches = [
    BranchInDb(id: 'b1', name: 'Sucursal Central', address: 'Av. 1', phone: '111', createdAt: 1000),
    BranchInDb(id: 'b2', name: 'Sucursal Norte', address: 'Av. 2', phone: '222', createdAt: 1000),
  ];

  testWidgets('AdministrationScreen renderiza cabecera, tarjetas de Aprobaciones y Usuarios, y módulo de reportes', (tester) async {
    final ordersRepo = MockOrdersRepo();
    final reportsRepo = MockReportsRepo();
    final sessionCubit = MockAppSessionCubit(adminUser, sampleBranches);

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<OrdersRepository>.value(value: ordersRepo),
          RepositoryProvider<ReportsRepository>.value(value: reportsRepo),
        ],
        child: BlocProvider<AppSessionCubit>.value(
          value: sessionCubit,
          child: const MaterialApp(
            home: AdministrationScreen(),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    // 1. Cabecera administrativa
    expect(find.text('Administración Central'), findsOneWidget);
    expect(find.text('Dra. Directora'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);

    // 2. Tarjetas ejecutivas
    expect(find.text('Aprobaciones'), findsOneWidget);
    expect(find.text('Usuarios'), findsOneWidget);

    // 3. Sección de Reportes
    expect(find.text('Reportes & Analíticas Multi-Sede'), findsOneWidget);

    // 4. Pestañas de Reportes
    expect(find.text('Finanzas'), findsOneWidget);
    expect(find.text('Top Médicos'), findsOneWidget);
    expect(find.text('Exámenes'), findsOneWidget);
    expect(find.text('Saldos'), findsOneWidget);
    expect(find.text('Turnos Caja'), findsOneWidget);
  });
}
