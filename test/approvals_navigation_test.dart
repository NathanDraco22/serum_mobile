import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_router.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import 'package:serum_mobile/src/modules/approvals/view/approvals_screen.dart';
import 'package:serum_mobile/src/modules/user/view/user_screen.dart';
import 'package:serum_mobile/src/modules/report/view/report_screen.dart';

class FakeOrdersRepo extends Fake implements OrdersRepository {
  @override
  Future<List<OrderInDb>> getAllOrders({OrderQueryParams? queryParams}) async => [];
  @override
  Stream<RepoEvent<OrderInDb>> get eventStream => const Stream.empty();
}

class FakeUsersRepo extends Fake implements UsersRepository {
  @override
  Future<List<UserInDb>> getAllUsers() async => [];
  @override
  Stream<RepoEvent<UserInDb>> get eventStream => const Stream.empty();
}

class FakeRolesRepo extends Fake implements RolesRepository {
  @override
  Future<List<RoleInDb>> getAllRoles() async => [];
  @override
  Stream<RepoEvent<RoleInDb>> get eventStream => const Stream.empty();
}

class FakeBranchesRepo extends Fake implements BranchesRepository {
  @override
  Future<List<BranchInDb>> getAllBranches() async => [];
  @override
  Stream<RepoEvent<BranchInDb>> get eventStream => const Stream.empty();
}

class FakeReportsRepo extends Fake implements ReportsRepository {
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
        totalBilled: 0,
        totalCollected: 0,
        ordersCount: 0,
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
      summary: LabTestsVolumeSummary(totalTestsCount: 0, topTests: []),
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
      summary: ShiftsAuditSummary(totalShifts: 0, totalDiscrepancies: 0),
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
      summary: TopDoctorsSummary(totalOrders: 0, totalRevenue: 0, topDoctors: []),
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
      summary: PendingBalancesSummary(totalPendingAmount: 0, ordersCount: 0),
    );
  }
}

class FakeAppSessionCubit extends Cubit<AppSessionState> implements AppSessionCubit {
  FakeAppSessionCubit(super.initialState);

  @override
  UserInDb? get currentUser => state.currentUser;

  @override
  Servin? get servin => state.servin;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final adminUser = UserInDb(
    id: 'admin_1',
    username: 'admin1',
    name: 'Director Médico',
    role: 'Admin',
    accessLevel: 5,
    createdAt: 1000000,
  );

  final sampleBranch = BranchInDb(
    id: 'branch-1',
    name: 'Sucursal Central',
    address: 'Av. Principal 123',
    phone: '555-1234',
    createdAt: 1000000,
  );

  group('Pruebas de Botón de Regreso y Navegación en Serum Mobile', () {
    testWidgets('ApprovalsScreen renderiza el botón de regreso (arrow_back_rounded) con tooltip', (tester) async {
      final fakeSessionCubit = FakeAppSessionCubit(
        AppSessionState(
          status: AppSessionStatus.authenticated,
          currentUser: adminUser,
          currentBranch: sampleBranch,
          branches: [sampleBranch],
        ),
      );

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<OrdersRepository>(create: (_) => FakeOrdersRepo()),
          ],
          child: BlocProvider<AppSessionCubit>.value(
            value: fakeSessionCubit,
            child: const MaterialApp(
              home: ApprovalsScreen(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Verifica título y botón de regreso en AppBar
      expect(find.text('Bandeja de Aprobaciones'), findsOneWidget);
      final backButtonFinder = find.widgetWithIcon(IconButton, Icons.arrow_back_rounded);
      expect(backButtonFinder, findsOneWidget);

      final iconBtn = tester.widget<IconButton>(backButtonFinder);
      expect(iconBtn.tooltip, 'Regresar');
    });

    testWidgets('ApprovalsScreen botón de regreso hace fallback a /dashboard cuando canPop es falso', (tester) async {
      final fakeSessionCubit = FakeAppSessionCubit(
        AppSessionState(
          status: AppSessionStatus.authenticated,
          currentUser: adminUser,
          currentBranch: sampleBranch,
          branches: [sampleBranch],
        ),
      );

      String currentPath = AppRouter.approvals;

      final testRouter = GoRouter(
        initialLocation: AppRouter.approvals,
        routes: [
          GoRoute(
            path: AppRouter.dashboard,
            builder: (context, state) {
              currentPath = AppRouter.dashboard;
              return const Scaffold(body: Text('Pantalla Dashboard'));
            },
          ),
          GoRoute(
            path: AppRouter.approvals,
            builder: (context, state) {
              currentPath = AppRouter.approvals;
              return const ApprovalsScreen();
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<OrdersRepository>(create: (_) => FakeOrdersRepo()),
          ],
          child: BlocProvider<AppSessionCubit>.value(
            value: fakeSessionCubit,
            child: MaterialApp.router(
              routerConfig: testRouter,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(currentPath, AppRouter.approvals);

      // Pulsar botón de regreso en ApprovalsScreen
      final backButtonFinder = find.widgetWithIcon(IconButton, Icons.arrow_back_rounded);
      expect(backButtonFinder, findsOneWidget);
      await tester.tap(backButtonFinder);
      await tester.pumpAndSettle();

      // Debe haber redirigido a dashboard
      expect(currentPath, AppRouter.dashboard);
      expect(find.text('Pantalla Dashboard'), findsOneWidget);
    });

    testWidgets('ApprovalsScreen botón de regreso ejecuta pop cuando canPop es verdadero', (tester) async {
      final fakeSessionCubit = FakeAppSessionCubit(
        AppSessionState(
          status: AppSessionStatus.authenticated,
          currentUser: adminUser,
          currentBranch: sampleBranch,
          branches: [sampleBranch],
        ),
      );

      final testRouter = GoRouter(
        initialLocation: AppRouter.dashboard,
        routes: [
          GoRoute(
            path: AppRouter.dashboard,
            builder: (context, state) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => context.push(AppRouter.approvals),
                  child: const Text('Ir a Aprobaciones'),
                ),
              );
            },
          ),
          GoRoute(
            path: AppRouter.approvals,
            builder: (context, state) => const ApprovalsScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<OrdersRepository>(create: (_) => FakeOrdersRepo()),
          ],
          child: BlocProvider<AppSessionCubit>.value(
            value: fakeSessionCubit,
            child: MaterialApp.router(
              routerConfig: testRouter,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navegar vía push hacia Aprobaciones
      await tester.tap(find.text('Ir a Aprobaciones'));
      await tester.pumpAndSettle();

      expect(find.text('Bandeja de Aprobaciones'), findsOneWidget);

      // Pulsar botón de regreso
      final backButton = find.widgetWithIcon(IconButton, Icons.arrow_back_rounded);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Regresó al Dashboard
      expect(find.text('Ir a Aprobaciones'), findsOneWidget);
      expect(find.text('Bandeja de Aprobaciones'), findsNothing);
    });

    testWidgets('UserScreen renderiza el botón de regreso (arrow_back_rounded) con fallback a admin', (tester) async {
      final fakeSessionCubit = FakeAppSessionCubit(
        AppSessionState(
          status: AppSessionStatus.authenticated,
          currentUser: adminUser,
        ),
      );

      String currentPath = AppRouter.users;

      final testRouter = GoRouter(
        initialLocation: AppRouter.users,
        routes: [
          GoRoute(
            path: AppRouter.admin,
            builder: (context, state) {
              currentPath = AppRouter.admin;
              return const Scaffold(body: Text('Pantalla Admin'));
            },
          ),
          GoRoute(
            path: AppRouter.users,
            builder: (context, state) {
              currentPath = AppRouter.users;
              return const UserScreen();
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<UsersRepository>(create: (_) => FakeUsersRepo()),
            RepositoryProvider<RolesRepository>(create: (_) => FakeRolesRepo()),
            RepositoryProvider<BranchesRepository>(create: (_) => FakeBranchesRepo()),
          ],
          child: BlocProvider<AppSessionCubit>.value(
            value: fakeSessionCubit,
            child: MaterialApp.router(
              routerConfig: testRouter,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Directorio de Personal'), findsOneWidget);
      final backButton = find.widgetWithIcon(IconButton, Icons.arrow_back_rounded);
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(currentPath, AppRouter.admin);
      expect(find.text('Pantalla Admin'), findsOneWidget);
    });

    testWidgets('ReportScreen renderiza el botón de regreso cuando showAppBar es true', (tester) async {
      final fakeSessionCubit = FakeAppSessionCubit(
        AppSessionState(
          status: AppSessionStatus.authenticated,
          currentUser: adminUser,
          currentBranch: sampleBranch,
          branches: [sampleBranch],
        ),
      );

      String currentPath = AppRouter.reports;

      final testRouter = GoRouter(
        initialLocation: AppRouter.reports,
        routes: [
          GoRoute(
            path: AppRouter.dashboard,
            builder: (context, state) {
              currentPath = AppRouter.dashboard;
              return const Scaffold(body: Text('Pantalla Dashboard'));
            },
          ),
          GoRoute(
            path: AppRouter.reports,
            builder: (context, state) {
              currentPath = AppRouter.reports;
              return const ReportScreen();
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<ReportsRepository>(create: (_) => FakeReportsRepo()),
          ],
          child: BlocProvider<AppSessionCubit>.value(
            value: fakeSessionCubit,
            child: MaterialApp.router(
              routerConfig: testRouter,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Reportes Ejecutivos'), findsOneWidget);
      final backButton = find.widgetWithIcon(IconButton, Icons.arrow_back_rounded);
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(currentPath, AppRouter.dashboard);
      expect(find.text('Pantalla Dashboard'), findsOneWidget);
    });
  });
}
