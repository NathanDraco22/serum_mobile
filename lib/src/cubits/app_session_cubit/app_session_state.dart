part of 'app_session_cubit.dart';

enum AppSessionStatus {
  initial,
  loading,
  unactivated,
  instanceInactive,
  authenticated,
  unauthenticated,
  insufficientPermissions,
  failure,
}

class AppSessionState {
  final AppSessionStatus status;
  final Servin? servin;
  final UserInDb? currentUser;
  final BranchInDb? currentBranch;
  final List<BranchInDb> branches;
  final String? errorMessage;

  const AppSessionState({
    this.status = AppSessionStatus.initial,
    this.servin,
    this.currentUser,
    this.currentBranch,
    this.branches = const [],
    this.errorMessage,
  });

  bool get isAuthenticated =>
      status == AppSessionStatus.authenticated && currentUser != null;

  bool get isSupervisor => (currentUser?.accessLevel ?? 0) > 3;

  bool get isAdmin =>
      currentUser != null &&
      (isRootUser ||
          (currentUser!.accessLevel >= 5) ||
          currentUser!.role.toLowerCase() == 'admin' ||
          currentUser!.role.toLowerCase() == 'administrador');

  bool get isRootUser =>
      currentUser != null &&
      (currentUser!.isRoot ||
          currentUser!.id == 'root' ||
          currentUser!.isInternal ||
          currentUser!.username.toLowerCase() == 'serum' ||
          currentUser!.username.toLowerCase() == 'root');

  bool get hasMultipleBranches => branches.length > 1;

  AppSessionState copyWith({
    AppSessionStatus? status,
    Servin? servin,
    UserInDb? currentUser,
    BranchInDb? currentBranch,
    List<BranchInDb>? branches,
    String? errorMessage,
    bool clearServin = false,
    bool clearUser = false,
    bool clearBranch = false,
    bool clearError = false,
  }) {
    return AppSessionState(
      status: status ?? this.status,
      servin: clearServin ? null : (servin ?? this.servin),
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      currentBranch: clearBranch ? null : (currentBranch ?? this.currentBranch),
      branches: branches ?? this.branches,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
