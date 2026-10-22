import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/cubits/user_cubit/user_mobile_cubit.dart';
import 'package:serum_mobile/src/cubits/user_cubit/user_mobile_state.dart';
import 'package:serum_mobile/src/modules/user/widgets/user_card.dart';
import 'package:serum_mobile/src/modules/user/widgets/user_form_modal.dart';
import 'package:serum_mobile/src/widgets/common/app_search_bar.dart';
import 'package:serum_mobile/src/widgets/common/empty_state_view.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserMobileCubit(
        usersRepository: context.read<UsersRepository>(),
        rolesRepository: context.read<RolesRepository>(),
        branchesRepository: context.read<BranchesRepository>(),
      ),
      child: const _UserView(),
    );
  }
}

class _UserView extends StatefulWidget {
  const _UserView();

  @override
  State<_UserView> createState() => _UserViewState();
}

class _UserViewState extends State<_UserView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreateModal(BuildContext context, UserMobileState state) {
    final cubit = context.read<UserMobileCubit>();
    UserFormModal.show(
      context,
      roles: state.roles,
      branches: state.branches,
      onSubmit: (newUser) => cubit.createUser(newUser),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<UserMobileCubit>();

    return BlocConsumer<UserMobileCubit, UserMobileState>(
      listener: (context, state) {
        if (state.actionSuccessMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionSuccessMessage!),
              backgroundColor: ColorPalette.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          cubit.clearMessages();
        } else if (state.errorMessage != null && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: ColorPalette.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          cubit.clearMessages();
        }
      },
      builder: (context, state) {
        final filteredUsers = state.filteredUsers;

        return Scaffold(
          backgroundColor: ColorPalette.surface,
          appBar: AppBar(
            title: Text(
              'Directorio de Personal',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Actualizar',
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => cubit.loadData(),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: ColorPalette.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.person_add_rounded),
            label: const Text(
              'Nuevo Usuario',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => _openCreateModal(context, state),
          ),
          body: RefreshIndicator(
            onRefresh: () => cubit.loadData(showLoading: false),
            child: Column(
              children: [
                // Barra de Búsqueda Reusable
                AppSearchBar(
                  controller: _searchController,
                  hintText: 'Buscar por nombre, usuario o email...',
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  onChanged: (q) => cubit.setSearchQuery(q),
                  onClear: () => cubit.setSearchQuery(''),
                ),

                // Contador de Personal y Filtro de Roles
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ColorPalette.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${state.activeUsersCount} activos de ${state.users.length}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: ColorPalette.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _RoleFilterChip(
                                label: 'Todos',
                                isSelected: state.selectedRoleFilter == null,
                                onTap: () => cubit.setRoleFilter(null),
                              ),
                              const SizedBox(width: 6),
                              ...state.roles.map((r) {
                                final isSelected =
                                    state.selectedRoleFilter?.toLowerCase() ==
                                        r.name.toLowerCase();
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: _RoleFilterChip(
                                    label: r.name,
                                    isSelected: isSelected,
                                    onTap: () => cubit.setRoleFilter(
                                      isSelected ? null : r.name,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: ColorPalette.outlineVariant),

                // Lista de Colaboradores
                Expanded(
                  child: state.isLoading && state.users.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : filteredUsers.isEmpty
                          ? EmptyStateView(
                              icon: Icons.person_search_rounded,
                              title: state.searchQuery.isNotEmpty ||
                                      state.selectedRoleFilter != null
                                  ? 'No se encontraron colaboradores'
                                  : 'No hay usuarios registrados',
                              message: state.searchQuery.isNotEmpty ||
                                      state.selectedRoleFilter != null
                                  ? 'Intenta con otros términos o limpia los filtros.'
                                  : 'Utiliza el botón flotante para crear el primer colaborador.',
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                              itemCount: filteredUsers.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                return UserCard(
                                  user: user,
                                  allBranches: state.branches,
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RoleFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorPalette.primary
              : ColorPalette.surfaceContainerHighest.withAlpha(40),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? ColorPalette.primary
                : ColorPalette.outlineVariant,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : ColorPalette.onSurface,
          ),
        ),
      ),
    );
  }
}
