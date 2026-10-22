import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_serum_config.dart';
import 'package:serum_mobile/src/core/app_config_manager.dart';

part 'app_session_state.dart';

class AppSessionCubit extends Cubit<AppSessionState> {
  final AuthRepository authRepository;
  final BranchesRepository branchesRepository;
  final UsersRepository usersRepository;
  final ServinRepository servinRepository;

  AppSessionCubit({
    required this.authRepository,
    required this.branchesRepository,
    required this.usersRepository,
    required this.servinRepository,
  }) : super(const AppSessionState());

  UserInDb? get currentUser => state.currentUser;
  BranchInDb? get currentBranch => state.currentBranch;
  Servin? get servin => state.servin;
  bool get hasMultipleBranches => state.hasMultipleBranches;
  bool get isRootUser => state.isRootUser;

  List<BranchInDb> _resolveAllowedBranches(
    UserInDb user,
    List<BranchInDb> allBranches,
  ) {
    final isRoot = user.isRoot ||
        user.id == 'root' ||
        user.isInternal ||
        user.username.toLowerCase() == 'serum' ||
        user.username.toLowerCase() == 'root';
    final isAdmin = user.role.toLowerCase() == 'admin';

    if (isRoot || isAdmin || user.branches.isEmpty) {
      return allBranches;
    }

    final filtered =
        allBranches.where((b) => user.branches.contains(b.id)).toList();
    return filtered.isNotEmpty ? filtered : allBranches;
  }

  void _updateNetworkConfig(Servin servin) {
    AppSerumConfig().setBaseUrl(servin.url);
    AppSerumConfig().setServinNickname(servin.nickname);
  }

  /// Inicializa la sesión validando primero la activación de la instancia (Servin).
  /// Si no existe Servin local, emite `unactivated`.
  /// Si existe Servin, valida su estado activo (`isActive`). Si está inactivo, emite `instanceInactive`.
  /// Luego valida los tokens y credenciales de supervisor del usuario.
  Future<void> initSession() async {
    emit(state.copyWith(status: AppSessionStatus.loading, clearError: true));

    try {
      final currentServin = await servinRepository.getCurrentServinFromLocal();
      if (currentServin == null) {
        emit(state.copyWith(
          status: AppSessionStatus.unactivated,
          clearUser: true,
          clearBranch: true,
          clearServin: true,
        ));
        return;
      }

      _updateNetworkConfig(currentServin);

      final savedBranchId = await AppConfigManager().getSelectedBranchId();
      if (savedBranchId != null && savedBranchId.isNotEmpty) {
        AppSerumConfig().setBranchId(savedBranchId);
      }

      // Validar si la instancia del laboratorio continúa activa en el backend
      final refreshedServin = await servinRepository.refreshServinStatus();
      final activeServin = refreshedServin ?? currentServin;

      if (!activeServin.isActive) {
        emit(state.copyWith(
          status: AppSessionStatus.instanceInactive,
          servin: activeServin,
          clearUser: true,
          clearBranch: true,
        ));
        return;
      }

      final token = await authRepository.ensureValidToken();
      if (token == null || token.isEmpty) {
        emit(state.copyWith(
          status: AppSessionStatus.unauthenticated,
          servin: activeServin,
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
          servin: activeServin,
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
          servin: activeServin,
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
          servin: activeServin,
          clearUser: true,
          clearBranch: true,
          errorMessage:
              'Acceso restringido: Esta aplicación es de uso exclusivo para supervisores y directores médicos (Nivel > 3). Por favor ingresa desde la terminal de ventanilla.',
        ));
        return;
      }

      // Cargar sucursales autorizadas
      List<BranchInDb> allBranches = [];
      try {
        allBranches = await branchesRepository.getAllBranches();
      } catch (_) {
        allBranches = branchesRepository.branches;
      }

      final branches = _resolveAllowedBranches(user, allBranches);

      BranchInDb? defaultBranch;
      if (branches.isNotEmpty) {
        if (savedBranchId != null && branches.any((b) => b.id == savedBranchId)) {
          defaultBranch = branches.firstWhere((b) => b.id == savedBranchId);
        } else if (user.branches.isNotEmpty) {
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
        servin: activeServin,
        clearError: true,
      ));
    } catch (e) {
      final currentServin = await servinRepository.getCurrentServinFromLocal();
      emit(state.copyWith(
        status: currentServin == null
            ? AppSessionStatus.unactivated
            : AppSessionStatus.unauthenticated,
        servin: currentServin,
        errorMessage: 'Error al inicializar sesión: $e',
      ));
    }
  }

  /// Inicia sesión con usuario/correo y contraseña, validando a su vez el estado de la instancia.
  Future<bool> login(String identifier, String password) async {
    emit(state.copyWith(status: AppSessionStatus.loading, clearError: true));

    try {
      final currentServin = await servinRepository.getCurrentServinFromLocal();
      if (currentServin == null) {
        emit(state.copyWith(
          status: AppSessionStatus.unactivated,
          clearUser: true,
          clearBranch: true,
          clearServin: true,
        ));
        return false;
      }

      _updateNetworkConfig(currentServin);

      // Iniciar sesión y validar estado de la instancia en paralelo
      final results = await Future.wait([
        authRepository.login(
          identifier: identifier.trim(),
          password: password,
        ),
        servinRepository.refreshServinStatus(),
      ]);

      final loginResponse = results[0] as LoginResponse;
      final refreshedServin = (results[1] as Servin?) ?? currentServin;

      if (!refreshedServin.isActive) {
        emit(state.copyWith(
          status: AppSessionStatus.instanceInactive,
          servin: refreshedServin,
          clearUser: true,
          clearBranch: true,
        ));
        return false;
      }

      final user = loginResponse.user;

      // Validación estricta de nivel de supervisor
      if (user.accessLevel <= 3) {
        await authRepository.logout();
        emit(state.copyWith(
          status: AppSessionStatus.insufficientPermissions,
          servin: refreshedServin,
          clearUser: true,
          clearBranch: true,
          errorMessage:
              'Acceso denegado: Tu cuenta cuenta con nivel ${user.accessLevel}. Serum Mobile requiere nivel de supervisor o directivo (> 3). Usa la versión de escritorio.',
        ));
        return false;
      }

      AppSerumConfig().authToken = loginResponse.token;

      // Cargar sucursales
      List<BranchInDb> allBranches = [];
      try {
        allBranches = await branchesRepository.getAllBranches();
      } catch (_) {
        allBranches = branchesRepository.branches;
      }

      final branches = _resolveAllowedBranches(user, allBranches);

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
        servin: refreshedServin,
        clearError: true,
      ));

      return true;
    } catch (e) {
      final currentServin = await servinRepository.getCurrentServinFromLocal();
      emit(state.copyWith(
        status: AppSessionStatus.failure,
        servin: currentServin,
        errorMessage: 'Credenciales inválidas o error de conexión: $e',
      ));
      return false;
    }
  }

  /// Configura una instancia recién activada y pasa a estado no autenticado (para hacer login)
  void initServinUnauthenticated(Servin servin) {
    _updateNetworkConfig(servin);
    emit(state.copyWith(
      status: AppSessionStatus.unauthenticated,
      servin: servin,
      clearUser: true,
      clearBranch: true,
      clearError: true,
    ));
  }

  /// Desvincula la instancia localmente y limpia la sesión completa para reconfigurar la app móvil.
  Future<void> exitBusiness() async {
    await servinRepository.clearCurrentServin();
    await authRepository.logout();
    await AppConfigManager().clearSelectedBranchId();
    AppSerumConfig().authToken = '';
    AppSerumConfig().setBranchId(null);
    AppSerumConfig().setServinNickname(null);

    emit(const AppSessionState(status: AppSessionStatus.unactivated));
  }

  /// Cambia la sucursal activa en la sesión móvil y persiste la preferencia.
  void selectBranch(BranchInDb branch) {
    AppSerumConfig().setBranchId(branch.id);
    AppConfigManager().saveSelectedBranchId(branch.id);
    emit(state.copyWith(currentBranch: branch));
  }

  /// Recarga la lista de sucursales autorizadas y mantiene sincronizada la sucursal activa.
  Future<void> refreshBranches() async {
    final user = state.currentUser;
    if (user == null) return;
    try {
      final allBranches = await branchesRepository.getAllBranches();
      final allowedBranches = _resolveAllowedBranches(user, allBranches);

      final currentStillAllowed =
          allowedBranches.any((b) => b.id == state.currentBranch?.id);
      final nextBranch = currentStillAllowed
          ? state.currentBranch
          : (allowedBranches.isNotEmpty ? allowedBranches.first : null);

      if (nextBranch != null && nextBranch.id != state.currentBranch?.id) {
        selectBranch(nextBranch);
      } else {
        emit(state.copyWith(branches: allowedBranches));
      }
    } catch (_) {}
  }

  /// Cierra la sesión activa del usuario y limpia tokens, manteniendo la instancia/negocio.
  Future<void> logout() async {
    try {
      await authRepository.logout();
    } catch (_) {}

    AppSerumConfig().authToken = '';
    AppSerumConfig().setBranchId(null);

    emit(state.copyWith(
      status: AppSessionStatus.unauthenticated,
      clearUser: true,
      clearBranch: true,
    ));
  }
}
