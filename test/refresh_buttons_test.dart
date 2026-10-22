import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import 'package:serum_mobile/src/modules/approvals/view/approvals_screen.dart';
import 'package:serum_mobile/src/modules/cash_shift/view/cash_shift_screen.dart';
import 'package:serum_mobile/src/modules/order/view/order_screen.dart';

class FakeAuthRepo extends Fake implements AuthRepository {}
class FakeBranchesRepo extends Fake implements BranchesRepository {}
class FakeUsersRepo extends Fake implements UsersRepository {}
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
  });
}
