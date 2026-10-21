import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_serum_config.dart';

part 'app_session_state.dart';

class AppSessionCubit extends Cubit<AppSessionState> {
  final AuthRepository authRepository;
  final BranchesRepository branchesRepository;
  final UsersRepository usersRepository;

  AppSessionCubit({
    required this.authRepository,
    required this.branchesRepository,
    required this.usersRepository,
  }) : super(const AppSessionState());

  UserInDb? get currentUser => state.currentUser;
  BranchInDb? get currentBranch => state.currentBranch;

  /// Inicializa la sesión validando los tokens persistidos y privilegios del usuario.
  Future<void> initSession() async {
    emit(state.copyWith(status: AppSessionStatus.loading, clearError: true));

    try {
      final token = await authRepository.ensureValidToken();
      if (token == null || token.isEmpty) {
        emit(state.copyWith(
          status: AppSessionStatus.unauthenticated,
          clearUser: true,
          clearBranch: true,
        ));
        return;
      }

      AppSerumConfig().authToken = token;

      // 1. Validar estado de la cuenta con checkUser
      final check = await authRepository.checkUser();
      if (check.isUnactive || check.isDeleted) {
        await authRepository.logout();
        emit(state.copyWith(
          status: AppSessionStatus.unauthenticated,
          clearUser: true,
          clearBranch: true,
          errorMessage: 'La cuenta ha sido desactivada o eliminada.',
        ));
        return;
      }

      // 2. Extraer usuario del token o consultar el repositorio
      final payload = TokenManager.decodePayload(token);
      final userId = payload?['userId'] as String?;

      UserInDb? user;
      if (userId != null && userId.isNotEmpty) {
        try {
          user = await usersRepository.getUserById(userId);
        } catch (_) {}
      }

      if (user == null) {
        await authRepository.logout();
        emit(state.copyWith(
          status: AppSessionStatus.unauthenticated,
          clearUser: true,
          clearBranch: true,
        ));
        return;
      }

      // Regla de Oro: Solo supervisores (accessLevel > 3) pueden ingresar a Serum Mobile
      if (user.accessLevel <= 3) {
        await authRepository.logout();
        emit(state.copyWith(
          status: AppSessionStatus.insufficientPermissions,
          clearUser: true,
          clearBranch: true,
          errorMessage:
              'Acceso restringido: Esta aplicación es de uso exclusivo para supervisores y directores médicos (Nivel > 3). Por favor ingresa desde la terminal de ventanilla.',
        ));
        return;
      }

      // Cargar sucursales autorizadas
      List<BranchInDb> branches = [];
      try {
        branches = await branchesRepository.getAllBranches();
      } catch (_) {
        branches = branchesRepository.branches;
      }

      BranchInDb? defaultBranch;
      if (branches.isNotEmpty) {
        if (user.branches.isNotEmpty) {
          defaultBranch = branches.firstWhere(
            (b) => user!.branches.contains(b.id),
            orElse: () => branches.first,
          );
        } else {
          defaultBranch = branches.first;
        }
      }

      if (defaultBranch != null) {
        AppSerumConfig().setBranchId(defaultBranch.id);
      }

      emit(state.copyWith(
        status: AppSessionStatus.authenticated,
        currentUser: user,
        currentBranch: defaultBranch,
        branches: branches,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AppSessionStatus.failure,
        errorMessage: 'Error al inicializar sesión: $e',
      ));
    }
  }

  /// Inicia sesión con usuario/correo y contraseña.
  Future<bool> login(String identifier, String password) async {
    emit(state.copyWith(status: AppSessionStatus.loading, clearError: true));

    try {
      final loginResponse = await authRepository.login(
        identifier: identifier.trim(),
        password: password,
      );

      final user = loginResponse.user;

      // Validación estricta de nivel de supervisor
      if (user.accessLevel <= 3) {
        await authRepository.logout();
        emit(state.copyWith(
          status: AppSessionStatus.insufficientPermissions,
          clearUser: true,
          clearBranch: true,
          errorMessage:
              'Acceso denegado: Tu cuenta cuenta con nivel ${user.accessLevel}. Serum Mobile requiere nivel de supervisor o directivo (> 3). Usa la versión de escritorio.',
        ));
        return false;
      }

      AppSerumConfig().authToken = loginResponse.token;

      // Cargar sucursales
      List<BranchInDb> branches = [];
      try {
        branches = await branchesRepository.getAllBranches();
      } catch (_) {
        branches = branchesRepository.branches;
      }

      BranchInDb? defaultBranch;
      if (branches.isNotEmpty) {
        if (user.branches.isNotEmpty) {
          defaultBranch = branches.firstWhere(
            (b) => user.branches.contains(b.id),
            orElse: () => branches.first,
          );
        } else {
          defaultBranch = branches.first;
        }
      }

      if (defaultBranch != null) {
        AppSerumConfig().setBranchId(defaultBranch.id);
      }

      emit(state.copyWith(
        status: AppSessionStatus.authenticated,
        currentUser: user,
        currentBranch: defaultBranch,
        branches: branches,
        clearError: true,
      ));

      return true;
    } catch (e) {
      emit(state.copyWith(
        status: AppSessionStatus.failure,
        errorMessage: 'Credenciales inválidas o error de conexión: $e',
      ));
      return false;
    }
  }

  /// Cambia la sucursal activa en la sesión móvil.
  void selectBranch(BranchInDb branch) {
    AppSerumConfig().setBranchId(branch.id);
    emit(state.copyWith(currentBranch: branch));
  }

  /// Cierra la sesión activa y limpia almacenamiento.
  Future<void> logout() async {
    try {
      await authRepository.logout();
    } catch (_) {}

    AppSerumConfig().authToken = '';
    AppSerumConfig().setBranchId(null);

    emit(const AppSessionState(status: AppSessionStatus.unauthenticated));
  }
}
