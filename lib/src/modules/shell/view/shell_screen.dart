import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../cubits/app_session_cubit/app_session_cubit.dart';

class _ShellDestination {
  final int branchIndex;
  final NavigationDestination destination;
  final bool adminOnly;

  const _ShellDestination({
    required this.branchIndex,
    required this.destination,
    this.adminOnly = false,
  });
}

class ShellScreen extends StatelessWidget {
  const ShellScreen({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const List<_ShellDestination> _allDestinations = [
    _ShellDestination(
      branchIndex: 0,
      destination: NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard_rounded),
        label: 'Inicio',
      ),
    ),
    _ShellDestination(
      branchIndex: 1,
      adminOnly: true,
      destination: NavigationDestination(
        icon: Icon(Icons.verified_user_outlined),
        selectedIcon: Icon(Icons.verified_user_rounded),
        label: 'Aprobaciones',
      ),
    ),
    _ShellDestination(
      branchIndex: 2,
      destination: NavigationDestination(
        icon: Icon(Icons.medical_services_outlined),
        selectedIcon: Icon(Icons.medical_services_rounded),
        label: 'Órdenes',
      ),
    ),
    _ShellDestination(
      branchIndex: 3,
      destination: NavigationDestination(
        icon: Icon(Icons.point_of_sale_outlined),
        selectedIcon: Icon(Icons.point_of_sale_rounded),
        label: 'Cajas',
      ),
    ),
    _ShellDestination(
      branchIndex: 4,
      adminOnly: true,
      destination: NavigationDestination(
        icon: Icon(Icons.manage_accounts_outlined),
        selectedIcon: Icon(Icons.manage_accounts_rounded),
        label: 'Usuarios',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final sessionState = context.watch<AppSessionCubit>().state;
    final isAdmin = sessionState.isAdmin;

    final visibleDestinations = _allDestinations
        .where((d) => !d.adminOnly || isAdmin)
        .toList();

    final currentBranch = navigationShell.currentIndex;
    final selectedIndex = visibleDestinations.indexWhere(
      (d) => d.branchIndex == currentBranch,
    );

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex >= 0 ? selectedIndex : 0,
        onDestinationSelected: (index) {
          final targetBranch = visibleDestinations[index].branchIndex;
          navigationShell.goBranch(
            targetBranch,
            initialLocation: targetBranch == currentBranch,
          );
        },
        destinations: visibleDestinations.map((d) => d.destination).toList(),
      ),
    );
  }
}
