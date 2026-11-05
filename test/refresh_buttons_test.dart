import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import 'package:serum_mobile/src/modules/administration/view/administration_screen.dart';
import 'package:serum_mobile/src/modules/approvals/view/approvals_screen.dart';
import 'package:serum_mobile/src/modules/cash_shift/view/cash_shift_screen.dart';
import 'package:serum_mobile/src/modules/dashboard/view/dashboard_screen.dart';
import 'package:serum_mobile/src/modules/inactive/view/inactive_screen.dart';
import 'package:serum_mobile/src/modules/order/view/order_screen.dart';
import 'package:serum_mobile/src/modules/report/view/report_screen.dart';
import 'package:serum_mobile/src/modules/user/view/user_screen.dart';

class FakeAuthRepo extends Fake implements AuthRepository {}
class FakeBranchesRepo extends Fake implements BranchesRepository {
  @override
  Future<List<BranchInDb>> getAllBranches() async => [];
}
class FakeUsersRepo extends Fake implements UsersRepository {
  @override
  Future<List<UserInDb>> getAllUsers({String? branchId}) async => [];
  @override
  Stream<RepoEvent<UserInDb>> get eventStream => const Stream.empty();
}
class FakeRolesRepo extends Fake implements RolesRepository {
  @override
  Future<List<RoleInDb>> getAllRoles() async => [];
}
class FakeServinRepo extends Fake implements ServinRepository {}

class FakeOrdersRepo extends Fake implements OrdersRepository {
  @override
  Future<List<OrderInDb>> getAllOrders({OrderQueryParams? queryParams}) async => [];
  @override
  Stream<RepoEvent<OrderInDb>> get eventStream => const Stream.empty();
}

class FakeCashShiftsRepo extends Fake implements CashShiftsRepository {
  @override
  Future<List<CashShiftInDb>> getAllCashShifts({
    String? branchId,
    String? userId,
    String? status,
  }) async => [];
  @override
  Stream<RepoEvent<CashShiftInDb>> get eventStream => const Stream.empty();
}

class FakeReportsRepo extends Fake implements ReportsRepository {
  @override
  Future<FinancialReportResponse> getFinancialReport({
    required int startDate,
    required int endDate,
    String? branchId,
  }) async => const FinancialReportResponse(
    startDate: 1000,
    endDate: 2000,
    summary: FinancialSummaryReport(
      totalBilled: 1000,
      totalCollected: 1000,
      ordersCount: 1,
    ),
  );

  @override
  Future<LabTestsVolumeReportResponse> getLabTestsVolumeReport({
    required int startDate,
    required int endDate,
    String? branchId,
    String source = 'orders',
    int limit = 10,
  }) async => const LabTestsVolumeReportResponse(
    startDate: 1000,
    endDate: 2000,
    summary: LabTestsVolumeSummary(totalTestsCount: 1, topTests: []),
  );

  @override
  Future<ShiftsAuditReportResponse> getShiftsAuditReport({
    required int startDate,
    required int endDate,
    String? branchId,
    bool onlyDiscrepancies = false,
  }) async => const ShiftsAuditReportResponse(
    startDate: 1000,
    endDate: 2000,
    summary: ShiftsAuditSummary(totalShifts: 2, totalDiscrepancies: 0),
  );

  @override
  Future<TopDoctorsReportResponse> getTopDoctorsReport({
    required int startDate,
    required int endDate,
    String? branchId,
    int limit = 10,
  }) async => const TopDoctorsReportResponse(
    startDate: 1000,
    endDate: 2000,
    summary: TopDoctorsSummary(totalOrders: 5, totalRevenue: 25000, topDoctors: []),
  );

  @override
  Future<PendingBalancesReportResponse> getPendingBalancesReport({
    required int startDate,
    required int endDate,
    String? branchId,
  }) async => const PendingBalancesReportResponse(
    startDate: 1000,
    endDate: 2000,
    summary: PendingBalancesSummary(totalPendingAmount: 12000, ordersCount: 3),
  );
}

void main() {
  group('Verificación de Botón de Actualizar y Pull-to-Refresh en Pantallas Móviles', () {
    late AppSessionCubit sessionCubit;

    setUp(() {
      sessionCubit = AppSessionCubit(
        authRepository: FakeAuthRepo(),
        branchesRepository: FakeBranchesRepo(),
        usersRepository: FakeUsersRepo(),
        servinRepository: FakeServinRepo(),
      );
    });

    tearDown(() {
      sessionCubit.close();
    });

    testWidgets('DashboardScreen contiene botón de refrescar y RefreshIndicator', (tester) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<OrdersRepository>(create: (_) => FakeOrdersRepo()),
            RepositoryProvider<CashShiftsRepository>(create: (_) => FakeCashShiftsRepo()),
          ],
          child: BlocProvider<AppSessionCubit>.value(
            value: sessionCubit,
            child: const MaterialApp(
              home: DashboardScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Serum Mobile'), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('ApprovalsScreen contiene botón de refrescar y RefreshIndicator', (tester) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<OrdersRepository>(create: (_) => FakeOrdersRepo()),
          ],
          child: BlocProvider<AppSessionCubit>.value(
            value: sessionCubit,
            child: const MaterialApp(
              home: ApprovalsScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Bandeja de Aprobaciones'), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('OrderScreen contiene botón de refrescar y RefreshIndicator', (tester) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<OrdersRepository>(create: (_) => FakeOrdersRepo()),
          ],
          child: BlocProvider<AppSessionCubit>.value(
            value: sessionCubit,
            child: const MaterialApp(
              home: OrderScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Órdenes Clínicas'), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('CashShiftScreen contiene botón de refrescar y RefreshIndicator', (tester) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<CashShiftsRepository>(create: (_) => FakeCashShiftsRepo()),
          ],
          child: BlocProvider<AppSessionCubit>.value(
            value: sessionCubit,
            child: const MaterialApp(
              home: CashShiftScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Monitor de Arqueos y Caja'), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('AdministrationScreen contiene botón de refrescar y RefreshIndicator', (tester) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<OrdersRepository>(create: (_) => FakeOrdersRepo()),
            RepositoryProvider<ReportsRepository>(create: (_) => FakeReportsRepo()),
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

      expect(find.text('Administración Central'), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('UserScreen contiene botón de refrescar y RefreshIndicator', (tester) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<UsersRepository>(create: (_) => FakeUsersRepo()),
            RepositoryProvider<RolesRepository>(create: (_) => FakeRolesRepo()),
            RepositoryProvider<BranchesRepository>(create: (_) => FakeBranchesRepo()),
          ],
          child: BlocProvider<AppSessionCubit>.value(
            value: sessionCubit,
            child: const MaterialApp(
              home: UserScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Directorio de Personal'), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('ReportScreen contiene botón de refrescar y RefreshIndicator', (tester) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<ReportsRepository>(create: (_) => FakeReportsRepo()),
          ],
          child: BlocProvider<AppSessionCubit>.value(
            value: sessionCubit,
            child: const MaterialApp(
              home: ReportScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('InactiveScreen contiene RefreshIndicator para reintento de conexión', (tester) async {
      await tester.pumpWidget(
        BlocProvider<AppSessionCubit>.value(
          value: sessionCubit,
          child: const MaterialApp(
            home: InactiveScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Instancia Desactivada'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('UserScreen pull-to-refresh responde en estado vacío sin lanzar excepciones', (tester) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<UsersRepository>(create: (_) => FakeUsersRepo()),
            RepositoryProvider<RolesRepository>(create: (_) => FakeRolesRepo()),
            RepositoryProvider<BranchesRepository>(create: (_) => FakeBranchesRepo()),
          ],
          child: BlocProvider<AppSessionCubit>.value(
            value: sessionCubit,
            child: const MaterialApp(
              home: UserScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No hay usuarios registrados'), findsOneWidget);
      await tester.fling(find.text('No hay usuarios registrados'), const Offset(0, 300), 1000);
      await tester.pump();
    });

    testWidgets('AdministrationScreen pull-to-refresh responde al arrastre sin excepciones', (tester) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<OrdersRepository>(create: (_) => FakeOrdersRepo()),
            RepositoryProvider<ReportsRepository>(create: (_) => FakeReportsRepo()),
          ],
          child: BlocProvider<AppSessionCubit>.value(
            value: sessionCubit,
            child: const MaterialApp(
              home: AdministrationScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.fling(find.text('Gestión y Autorizaciones'), const Offset(0, 300), 1000);
      await tester.pump();
    });
  });
}
