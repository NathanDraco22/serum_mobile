part of 'app_session_cubit.dart';

enum AppSessionStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  insufficientPermissions,
  failure,
}

class AppSessionState {
  final AppSessionStatus status;
  final UserInDb? currentUser;
  final BranchInDb? currentBranch;
  final List<BranchInDb> branches;
  final String? errorMessage;

  const AppSessionState({
    this.status = AppSessionStatus.initial,
    this.currentUser,
    this.currentBranch,
    this.branches = const [],
    this.errorMessage,
  });

  bool get isAuthenticated =>
      status == AppSessionStatus.authenticated && currentUser != null;

  bool get isSupervisor => (currentUser?.accessLevel ?? 0) > 3;

  AppSessionState copyWith({
    AppSessionStatus? status,
    UserInDb? currentUser,
    BranchInDb? currentBranch,
    List<BranchInDb>? branches,
    String? errorMessage,
    bool clearUser = false,
    bool clearBranch = false,
    bool clearError = false,
  }) {
    return AppSessionState(
      status: status ?? this.status,
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      currentBranch: clearBranch ? null : (currentBranch ?? this.currentBranch),
      branches: branches ?? this.branches,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
