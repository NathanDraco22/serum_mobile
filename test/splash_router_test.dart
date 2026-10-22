import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_router.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import 'package:serum_mobile/src/modules/splash/view/splash_screen.dart';
import 'package:serum_mobile/src/modules/activation/view/activation_screen.dart';
import 'package:serum_mobile/src/modules/auth/view/login_screen.dart';
import 'package:serum_mobile/src/modules/shell/view/shell_screen.dart';

class MockServinRepository implements ServinRepository {
  Servin? currentServin;

  @override
  Future<Servin?> getCurrentServinFromLocal() async => currentServin;

  @override
  Future<Servin?> refreshServinStatus() async => currentServin;

  @override
  Future<Servin> getActiveServin(String apiKey, String nickname, {String? originServerUrl}) async {
    return Servin(name: 'Test', nickname: nickname, url: 'http://localhost:8000', isActive: true);
  }

  @override
  Future<void> clearCurrentServin() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAppSessionCubit extends Cubit<AppSessionState> implements AppSessionCubit {
  FakeAppSessionCubit([AppSessionState? initialState])
      : super(initialState ?? const AppSessionState(status: AppSessionStatus.initial));

  @override
  Servin? get servin => state.servin;

  void emitState(AppSessionState newState) {
    emit(newState);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('SplashScreen & AppRouter Redirection Tests', () {
    testWidgets('SplashScreen renderiza correctamente el icono, título y spinner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );
      await tester.pump();

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('Serum Mobile'), findsOneWidget);
      expect(find.text('Supervisión y Control Clínico'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.local_hospital_rounded), findsOneWidget);
    });

    testWidgets('AppRouter arranca en /splash en estado initial y no monta ShellScreen', (tester) async {
      final fakeCubit = FakeAppSessionCubit(
        const AppSessionState(status: AppSessionStatus.initial),
      );
      final router = AppRouter.createRouter(fakeCubit);

      await tester.pumpWidget(
        BlocProvider<AppSessionCubit>.value(
          value: fakeCubit,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Debe mostrar SplashScreen y NO ShellScreen ni ActivationScreen
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(ShellScreen), findsNothing);
      expect(find.byType(ActivationScreen), findsNothing);
    });

    testWidgets('AppRouter transiciona de /splash a /activation al emitir unactivated', (tester) async {
      final fakeCubit = FakeAppSessionCubit(
        const AppSessionState(status: AppSessionStatus.initial),
      );
      final router = AppRouter.createRouter(fakeCubit);
      final mockServinRepo = MockServinRepository();

      await tester.pumpWidget(
        RepositoryProvider<ServinRepository>.value(
          value: mockServinRepo,
          child: BlocProvider<AppSessionCubit>.value(
            value: fakeCubit,
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pump();

      // Inicialmente en splash
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(ShellScreen), findsNothing);

      // Se emite unactivated
      fakeCubit.emitState(const AppSessionState(status: AppSessionStatus.unactivated));
      await tester.pumpAndSettle();

      // Ahora está en ActivationScreen y NUNCA se montó ShellScreen
      expect(find.byType(ActivationScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(ShellScreen), findsNothing);
    });

    testWidgets('AppRouter transiciona de /splash a /login al emitir unauthenticated', (tester) async {
      final fakeCubit = FakeAppSessionCubit(
        const AppSessionState(status: AppSessionStatus.initial),
      );
      final router = AppRouter.createRouter(fakeCubit);
      final mockServinRepo = MockServinRepository();

      await tester.pumpWidget(
        RepositoryProvider<ServinRepository>.value(
          value: mockServinRepo,
          child: BlocProvider<AppSessionCubit>.value(
            value: fakeCubit,
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SplashScreen), findsOneWidget);

      // Emitir unauthenticated con una instancia configurada
      fakeCubit.emitState(
        AppSessionState(
          status: AppSessionStatus.unauthenticated,
          servin: Servin(
            name: 'Laboratorio San José',
            nickname: 'lab-sj',
            url: 'http://localhost:8000',
            isActive: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(ShellScreen), findsNothing);
    });
  });
}
