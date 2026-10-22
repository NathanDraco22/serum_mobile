import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/src/cubits/user_cubit/user_mobile_state.dart';

class UserMobileCubit extends Cubit<UserMobileState> {
  final UsersRepository usersRepository;
  final RolesRepository rolesRepository;
  final BranchesRepository branchesRepository;

  StreamSubscription? _usersSub;

  UserMobileCubit({
    required this.usersRepository,
    required this.rolesRepository,
    required this.branchesRepository,
  }) : super(const UserMobileState()) {
    loadData();
    _subscribeToEvents();
  }

  void _subscribeToEvents() {
    _usersSub = usersRepository.eventStream.listen((event) {
      loadData(showLoading: false);
    });
  }

  @override
  Future<void> close() {
    _usersSub?.cancel();
    return super.close();
  }

  Future<void> loadData({bool showLoading = true}) async {
    if (showLoading) {
      emit(state.copyWith(
        status: UserMobileStatus.loading,
        errorMessage: null,
      ));
    }

    try {
      final results = await Future.wait([
        usersRepository.getAllUsers(),
        rolesRepository.getAllRoles(),
        branchesRepository.getAllBranches(),
      ]);

      emit(state.copyWith(
        status: UserMobileStatus.success,
        users: results[0] as List<UserInDb>,
        roles: results[1] as List<RoleInDb>,
        branches: results[2] as List<BranchInDb>,
        errorMessage: null,
      ));
    } catch (e, stack) {
      debugPrint('[UserMobileCubit] Error al cargar colaboradores: $e\n$stack');
      emit(state.copyWith(
        status: UserMobileStatus.failure,
        errorMessage: 'Error al consultar colaboradores: $e',
      ));
    }
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setRoleFilter(String? role) {
    if (role == null) {
      emit(state.copyWith(clearRoleFilter: true));
    } else {
      emit(state.copyWith(selectedRoleFilter: role));
    }
  }

  Future<bool> createUser(CreateUser newUser) async {
    emit(state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      actionSuccessMessage: null,
    ));

    try {
      await usersRepository.createUser(newUser);
      emit(state.copyWith(
        isSubmitting: false,
        actionSuccessMessage: 'Usuario "${newUser.name}" creado correctamente',
      ));
      return true;
    } catch (e, stack) {
      debugPrint('[UserMobileCubit] Error al crear usuario: $e\n$stack');
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Error al registrar usuario: $e',
      ));
      return false;
    }
  }

  void clearMessages() {
    emit(state.copyWith(
      errorMessage: null,
      actionSuccessMessage: null,
    ));
  }
}
