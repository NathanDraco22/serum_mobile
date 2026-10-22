import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_router.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import 'package:serum_mobile/src/modules/approvals/view/approvals_screen.dart';
import 'package:serum_mobile/src/modules/dashboard/view/dashboard_screen.dart';
import 'package:serum_mobile/src/modules/dashboard/widgets/pending_approvals_banner.dart';

class FakeAuthRepo extends Fake implements AuthRepository {}
class FakeBranchesRepo extends Fake implements BranchesRepository {}
class FakeUsersRepo extends Fake implements UsersRepository {
  @override
  Future<List<UserInDb>> getAllUsers() async => [];
  @override
  Stream<RepoEvent<UserInDb>> get eventStream => const Stream.empty();
}
class FakeServinRepo extends Fake implements ServinRepository {
  @override
  Future<Servin?> refreshServinStatus() async => null;
}
class FakeOrdersRepo extends Fake implements OrdersRepository {
  @override
  Future<List<OrderInDb>> getAllOrders({OrderQueryParams? queryParams}) async => [];
  @override
  Stream<RepoEvent<OrderInDb>> get eventStream => const Stream.empty();
}
class FakeCashShiftsRepo extends Fake implements CashShiftsRepository {
  @override
  Future<List<CashShiftInDb>> getAllCashShifts({String? branchId, String? userId, String? status}) async => [];
  @override
  Stream<RepoEvent<CashShiftInDb>> get eventStream => const Stream.empty();
}
class FakeRolesRepo extends Fake implements RolesRepository {
  @override
  Future<List<RoleInDb>> getAllRoles() async => [];
  @override
  Stream<RepoEvent<RoleInDb>> get eventStream => const Stream.empty();
}

class FakeAppSessionCubit extends Cubit<AppSessionState> implements AppSessionCubit {
  FakeAppSessionCubit(super.initialState);

  @override
  Servin? get servin => state.servin;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Pruebas de Permisos Exclusivos de Administrador en Serum Mobile', () {
    final regularSupervisor = UserInDb(
      id: 'sup_1',
      username: 'supervisor1',
      name: 'Supervisor Clínico',
      role: 'Supervisor',
      accessLevel: 4,
      createdAt: 1000000,
    );

    final adminUser = UserInDb(
      id: 'admin_1',
      username: 'admin1',
      name: 'Director Médico',
      role: 'Admin',
      accessLevel: 5,
      createdAt: 1000000,
    );

    final rootUser = UserInDb(
      id: 'root',
      username: 'Serum',
      name: 'Root Master',
      role: 'SuperUser',
      accessLevel: 5,
      createdAt: 1000000,
    );

    test('AppSessionState.isAdmin identifica correctamente administradores vs supervisores', () {
      const emptyState = AppSessionState(status: AppSessionStatus.unauthenticated);
      expect(emptyState.isAdmin, isFalse);

      final supervisorState = AppSessionState(
        status: AppSessionStatus.authenticated,
        currentUser: regularSupervisor,
      );
      expect(supervisorState.isSupervisor, isTrue);
      expect(supervisorState.isAdmin, isFalse);

      final adminState = AppSessionState(
        status: AppSessionStatus.authenticated,
        currentUser: adminUser,
      );
      expect(adminState.isSupervisor, isTrue);
      expect(adminState.isAdmin, isTrue);

      final rootState = AppSessionState(
        status: AppSessionStatus.authenticated,
        currentUser: rootUser,
      );
      expect(rootState.isAdmin, isTrue);

      // Usuario con rol 'Administrador' y nivel 4 también califica por nombre de rol
      final adminByNameUser = UserInDb(
        id: 'admin_2',
        username: 'admin2',
        name: 'Administrador 2',
        role: 'Administrador',
        accessLevel: 4,
        createdAt: 1000000,
      );
      final adminByNameState = AppSessionState(
        status: AppSessionStatus.authenticated,
        currentUser: adminByNameUser,
      );
      expect(adminByNameState.isAdmin, isTrue);
    });

    testWidgets('AppRouter redirige a /dashboard si un no-admin intenta acceder a /approvals o /users', (tester) async {
      final fakeCubit = FakeAppSessionCubit(
        AppSessionState(
          status: AppSessionStatus.authenticated,
          currentUser: regularSupervisor,
        ),
      );

      final router = AppRouter.createRouter(
        fakeCubit,
        initialLocation: AppRouter.approvals,
      );

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<OrdersRepository>(create: (_) => FakeOrdersRepo()),
            RepositoryProvider<CashShiftsRepository>(create: (_) => FakeCashShiftsRepo()),
            RepositoryProvider<UsersRepository>(create: (_) => FakeUsersRepo()),
            RepositoryProvider<RolesRepository>(create: (_) => FakeRolesRepo()),
            RepositoryProvider<BranchesRepository>(create: (_) => FakeBranchesRepo()),
          ],
          child: BlocProvider<AppSessionCubit>.value(
            value: fakeCubit,
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Debe haber sido redirigido al Dashboard y no estar en ApprovalsScreen
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(ApprovalsScreen), findsNothing);
    });

    testWidgets('AppRouter permite el acceso a /approvals y /users cuando el usuario es admin', (tester) async {
      final fakeCubit = FakeAppSessionCubit(
        AppSessionState(
          status: AppSessionStatus.authenticated,
          currentUser: adminUser,
        ),
      );

      final router = AppRouter.createRouter(
        fakeCubit,
        initialLocation: AppRouter.approvals,
      );

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<OrdersRepository>(create: (_) => FakeOrdersRepo()),
            RepositoryProvider<CashShiftsRepository>(create: (_) => FakeCashShiftsRepo()),
            RepositoryProvider<UsersRepository>(create: (_) => FakeUsersRepo()),
            RepositoryProvider<RolesRepository>(create: (_) => FakeRolesRepo()),
            RepositoryProvider<BranchesRepository>(create: (_) => FakeBranchesRepo()),
          ],
          child: BlocProvider<AppSessionCubit>.value(
            value: fakeCubit,
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Debe mostrar ApprovalsScreen para el admin
      expect(find.byType(ApprovalsScreen), findsOneWidget);
    });

    testWidgets('ShellScreen muestra 3 destinos para supervisor regular y 5 para admin', (tester) async {
      // 1. Caso Supervisor regular: solo 3 destinos
      final supervisorCubit = FakeAppSessionCubit(
        AppSessionState(
          status: AppSessionStatus.authenticated,
          currentUser: regularSupervisor,
        ),
      );

      final routerSup = AppRouter.createRouter(
        supervisorCubit,
        initialLocation: AppRouter.dashboard,
      );

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<OrdersRepository>(create: (_) => FakeOrdersRepo()),
            RepositoryProvider<CashShiftsRepository>(create: (_) => FakeCashShiftsRepo()),
            RepositoryProvider<UsersRepository>(create: (_) => FakeUsersRepo()),
            RepositoryProvider<RolesRepository>(create: (_) => FakeRolesRepo()),
            RepositoryProvider<BranchesRepository>(create: (_) => FakeBranchesRepo()),
          ],
          child: BlocProvider<AppSessionCubit>.value(
            value: supervisorCubit,
            child: MaterialApp.router(
              routerConfig: routerSup,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final navBarSup = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBarSup.destinations.length, equals(3));
      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Órdenes'), findsOneWidget);
      expect(find.text('Cajas'), findsOneWidget);
      expect(find.text('Aprobaciones'), findsNothing);
      expect(find.text('Usuarios'), findsNothing);

      // 2. Caso Admin: 5 destinos
      final adminCubit = FakeAppSessionCubit(
        AppSessionState(
          status: AppSessionStatus.authenticated,
          currentUser: adminUser,
        ),
      );

      final routerAdmin = AppRouter.createRouter(
        adminCubit,
        initialLocation: AppRouter.dashboard,
      );

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<OrdersRepository>(create: (_) => FakeOrdersRepo()),
            RepositoryProvider<CashShiftsRepository>(create: (_) => FakeCashShiftsRepo()),
            RepositoryProvider<UsersRepository>(create: (_) => FakeUsersRepo()),
            RepositoryProvider<RolesRepository>(create: (_) => FakeRolesRepo()),
            RepositoryProvider<BranchesRepository>(create: (_) => FakeBranchesRepo()),
          ],
          child: BlocProvider<AppSessionCubit>.value(
            value: adminCubit,
            child: MaterialApp.router(
              routerConfig: routerAdmin,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final navBarAdmin = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBarAdmin.destinations.length, equals(5));
      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Aprobaciones'), findsOneWidget);
      expect(find.text('Órdenes'), findsOneWidget);
      expect(find.text('Cajas'), findsOneWidget);
      expect(find.text('Usuarios'), findsOneWidget);
    });

    testWidgets('DashboardScreen oculta el banner de aprobaciones y la tarjeta Por Autorizar para no-admins', (tester) async {
      final supervisorCubit = FakeAppSessionCubit(
        AppSessionState(
          status: AppSessionStatus.authenticated,
          currentUser: regularSupervisor,
        ),
      );

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<OrdersRepository>(create: (_) => FakeOrdersRepo()),
            RepositoryProvider<CashShiftsRepository>(create: (_) => FakeCashShiftsRepo()),
          ],
          child: BlocProvider<AppSessionCubit>.value(
            value: supervisorCubit,
            child: const MaterialApp(
              home: DashboardScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // No debe existir el banner de aprobaciones ni la tarjeta Por Autorizar
      expect(find.byType(PendingApprovalsBanner), findsNothing);
      expect(find.text('Por Autorizar'), findsNothing);
      expect(find.text('Ventas Totales'), findsOneWidget);
      expect(find.text('Órdenes Clínicas'), findsOneWidget);
      expect(find.text('Turnos de Caja'), findsOneWidget);
    });
  });
}
