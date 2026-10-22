import 'package:flutter_test/flutter_test.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_serum_config.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import 'package:serum_mobile/src/modules/activation/cubit/activation_cubit.dart';

class MockServinRepository implements ServinRepository {
  Servin? currentServin;
  Servin? refreshedServin;
  bool shouldThrow = false;
  String? lastApiKey;
  String? lastNickname;

  @override
  Future<Servin?> getCurrentServinFromLocal() async {
    return currentServin;
  }

  @override
  Future<Servin?> refreshServinStatus() async {
    return refreshedServin ?? currentServin;
  }

  @override
  Future<Servin> getActiveServin(
    String apiKey,
    String nickname, {
    String? originServerUrl,
  }) async {
    if (shouldThrow) {
      throw Exception('Instancia no encontrada o clave inválida');
    }
    lastApiKey = apiKey;
    lastNickname = nickname;
    final servin = Servin(
      name: 'Laboratorio San José',
      nickname: nickname,
      url: originServerUrl ?? 'http://127.0.0.1:8000',
      isActive: true,
    );
    currentServin = servin;
    return servin;
  }

  @override
  Future<void> clearCurrentServin() async {
    currentServin = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthRepository implements AuthRepository {
  bool loggedOut = false;

  @override
  Future<String?> ensureValidToken({Duration threshold = const Duration(minutes: 5)}) async {
    return null;
  }

  @override
  Future<void> logout() async {
    loggedOut = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockBranchesRepository implements BranchesRepository {
  @override
  List<BranchInDb> get branches => [];

  @override
  Future<List<BranchInDb>> getAllBranches() async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUsersRepository implements UsersRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Activation & Session Tests en Serum Mobile', () {
    late MockServinRepository mockServinRepo;
    late MockAuthRepository mockAuthRepo;
    late MockBranchesRepository mockBranchesRepo;
    late MockUsersRepository mockUsersRepo;
    late AppSessionCubit sessionCubit;

    setUp(() {
      mockServinRepo = MockServinRepository();
      mockAuthRepo = MockAuthRepository();
      mockBranchesRepo = MockBranchesRepository();
      mockUsersRepo = MockUsersRepository();

      sessionCubit = AppSessionCubit(
        authRepository: mockAuthRepo,
        branchesRepository: mockBranchesRepo,
        usersRepository: mockUsersRepo,
        servinRepository: mockServinRepo,
      );
    });

    tearDown(() {
      sessionCubit.close();
    });

    test('initSession() sin Servin local emite AppSessionStatus.unactivated', () async {
      mockServinRepo.currentServin = null;

      await sessionCubit.initSession();

      expect(sessionCubit.state.status, AppSessionStatus.unactivated);
      expect(sessionCubit.state.servin, isNull);
    });

    test('initSession() con Servin inactivo emite AppSessionStatus.instanceInactive', () async {
      final inactiveServin = Servin(
        name: 'Laboratorio Suspendido',
        nickname: 'lab-suspendido',
        url: 'http://127.0.0.1:8000',
        isActive: false,
      );

      mockServinRepo.currentServin = inactiveServin;
      mockServinRepo.refreshedServin = inactiveServin;

      await sessionCubit.initSession();

      expect(sessionCubit.state.status, AppSessionStatus.instanceInactive);
      expect(sessionCubit.state.servin?.name, 'Laboratorio Suspendido');
    });

    test('initServinUnauthenticated() configura red y emite unauthenticated con servin', () {
      final servin = Servin(
        name: 'Laboratorio Metropolitano',
        nickname: 'lab-metro',
        url: 'http://192.168.1.50:8000',
        isActive: true,
      );

      sessionCubit.initServinUnauthenticated(servin);

      expect(sessionCubit.state.status, AppSessionStatus.unauthenticated);
      expect(sessionCubit.state.servin?.nickname, 'lab-metro');
      expect(AppSerumConfig().baseUrl, 'http://192.168.1.50:8000');
      expect(AppSerumConfig().servinNickname, 'lab-metro');
    });

    test('exitBusiness() limpia configuración y emite unactivated', () async {
      await sessionCubit.exitBusiness();

      expect(sessionCubit.state.status, AppSessionStatus.unactivated);
      expect(sessionCubit.state.servin, isNull);
      expect(mockServinRepo.currentServin, isNull);
      expect(mockAuthRepo.loggedOut, isTrue);
    });

    test('ActivationCubit valida campos vacíos y emite ActivationError', () async {
      final activationCubit = ActivationCubit(mockServinRepo);

      await activationCubit.activate('', 'lab-alias');
      expect(activationCubit.state, isA<ActivationError>());
      expect(
        (activationCubit.state as ActivationError).message,
        contains('clave de activación'),
      );

      await activationCubit.activate('api_key', '   ');
      expect(activationCubit.state, isA<ActivationError>());
      expect(
        (activationCubit.state as ActivationError).message,
        contains('alias del negocio'),
      );

      await activationCubit.close();
    });

    test('ActivationCubit activa correctamente y emite ActivationSuccess', () async {
      final activationCubit = ActivationCubit(mockServinRepo);

      final future = activationCubit.activate(
        'sk_live_12345',
        'clinica-central',
        originServerUrl: 'http://server.test:8000',
      );

      await future;

      expect(activationCubit.state, isA<ActivationSuccess>());
      final success = activationCubit.state as ActivationSuccess;
      expect(success.servin.name, 'Laboratorio San José');
      expect(success.servin.nickname, 'clinica-central');
      expect(success.servin.url, 'http://server.test:8000');

      await activationCubit.close();
    });
  });
}
