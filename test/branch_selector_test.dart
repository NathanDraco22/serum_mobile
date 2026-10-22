import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_serum_config.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import 'package:serum_mobile/src/modules/dashboard/widgets/branch_selector_modal.dart';
import 'package:serum_mobile/src/modules/dashboard/widgets/supervisor_header_card.dart';

class FakeAuthRepo extends Fake implements AuthRepository {}
class FakeBranchesRepo extends Fake implements BranchesRepository {}
class FakeUsersRepo extends Fake implements UsersRepository {}
class FakeServinRepo extends Fake implements ServinRepository {}

void main() {
  group('Pruebas de Selector y Alternador de Sucursales en Serum Mobile', () {
    final branchMatriz = BranchInDb(
      id: 'branch_matriz',
      name: 'Sucursal Matriz',
      address: 'Calle 10 #20-30',
      phone: '1234567',
      createdAt: 1000,
    );

    final branchNorte = BranchInDb(
      id: 'branch_norte',
      name: 'Sucursal Norte',
      address: 'Avenida Norte #50-10',
      phone: '7654321',
      createdAt: 2000,
    );

    test('AppSessionState detecta hasMultipleBranches e isRootUser correctamente', () {
      final userRoot = UserInDb(
        id: 'root',
        username: 'serum',
        name: 'Administrador Serum',
        role: 'Admin',
        accessLevel: 5,
        isActive: true,
        isDeleted: false,
        branches: ['branch_matriz'],
        createdAt: 1000,
      );

      final stateSingle = AppSessionState(
        status: AppSessionStatus.authenticated,
        currentUser: userRoot,
        currentBranch: branchMatriz,
        branches: [branchMatriz],
      );

      expect(stateSingle.isRootUser, isTrue);
      expect(stateSingle.hasMultipleBranches, isFalse);

      final stateMultiple = stateSingle.copyWith(
        branches: [branchMatriz, branchNorte],
      );

      expect(stateMultiple.hasMultipleBranches, isTrue);
    });

    test('selectBranch actualiza currentBranch y la configuración global de red', () {
      final cubit = AppSessionCubit(
        authRepository: FakeAuthRepo(),
        branchesRepository: FakeBranchesRepo(),
        usersRepository: FakeUsersRepo(),
        servinRepository: FakeServinRepo(),
      );

      cubit.selectBranch(branchNorte);

      expect(cubit.state.currentBranch?.id, equals('branch_norte'));
      expect(AppSerumConfig().branchId, equals('branch_norte'));
    });

    testWidgets('SupervisorHeaderCard muestra indicador táctil cuando onTapBranch está presente', (tester) async {
      bool tapped = false;

      final supervisor = UserInDb(
        id: 'u1',
        username: 'dr.garcia',
        name: 'Dr. Roberto García',
        role: 'Supervisor',
        accessLevel: 4,
        isActive: true,
        isDeleted: false,
        branches: ['branch_matriz', 'branch_norte'],
        createdAt: 1000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SupervisorHeaderCard(
              user: supervisor,
              branch: branchMatriz,
              onTapBranch: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Dr. Roberto García'), findsOneWidget);
      expect(find.text('Sucursal Matriz'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);

      await tester.tap(find.text('Sucursal Matriz'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('BranchSelectorModal lista sucursales y llama onBranchSelected al pulsar', (tester) async {
      BranchInDb? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BranchSelectorModal(
              branches: [branchMatriz, branchNorte],
              currentBranch: branchMatriz,
              onBranchSelected: (b) {
                selected = b;
              },
            ),
          ),
        ),
      );

      expect(find.text('Seleccionar Sucursal'), findsOneWidget);
      expect(find.text('Sucursal Matriz'), findsOneWidget);
      expect(find.text('Sucursal Norte'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      await tester.tap(find.text('Sucursal Norte'));
      await tester.pump();

      expect(selected?.id, equals('branch_norte'));
    });
  });
}
