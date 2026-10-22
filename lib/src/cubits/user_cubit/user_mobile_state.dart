import 'package:serum_business/serum_business.dart';

enum UserMobileStatus { initial, loading, success, failure }

class UserMobileState {
  final UserMobileStatus status;
  final List<UserInDb> users;
  final List<RoleInDb> roles;
  final List<BranchInDb> branches;
  final String searchQuery;
  final String? selectedRoleFilter;
  final bool isSubmitting;
  final String? errorMessage;
  final String? actionSuccessMessage;

  const UserMobileState({
    this.status = UserMobileStatus.initial,
    this.users = const [],
    this.roles = const [],
    this.branches = const [],
    this.searchQuery = '',
    this.selectedRoleFilter,
    this.isSubmitting = false,
    this.errorMessage,
    this.actionSuccessMessage,
  });

  bool get isLoading => status == UserMobileStatus.loading;
  int get activeUsersCount => users.where((u) => u.isActive && !u.isDeleted).length;

  List<UserInDb> get filteredUsers {
    return users.where((user) {
      if (user.isDeleted) return false;

      // Filtro por Rol
      if (selectedRoleFilter != null && selectedRoleFilter!.isNotEmpty) {
        if (user.role.toLowerCase() != selectedRoleFilter!.toLowerCase()) {
          return false;
        }
      }

      // Filtro por Búsqueda
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase().trim();
        final matchName = user.name.toLowerCase().contains(q);
        final matchUsername = user.username.toLowerCase().contains(q);
        final matchEmail = user.email?.toLowerCase().contains(q) ?? false;
        final matchPhone = user.phone?.toLowerCase().contains(q) ?? false;
        if (!matchName && !matchUsername && !matchEmail && !matchPhone) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  UserMobileState copyWith({
    UserMobileStatus? status,
    List<UserInDb>? users,
    List<RoleInDb>? roles,
    List<BranchInDb>? branches,
    String? searchQuery,
    String? selectedRoleFilter,
    bool clearRoleFilter = false,
    bool? isSubmitting,
    String? errorMessage,
    String? actionSuccessMessage,
  }) {
    return UserMobileState(
      status: status ?? this.status,
      users: users ?? this.users,
      roles: roles ?? this.roles,
      branches: branches ?? this.branches,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedRoleFilter: clearRoleFilter
          ? null
          : (selectedRoleFilter ?? this.selectedRoleFilter),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      actionSuccessMessage: actionSuccessMessage,
    );
  }
}
