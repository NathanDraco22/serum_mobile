import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../src/cubits/app_session_cubit/app_session_cubit.dart';
import '../src/modules/splash/view/splash_screen.dart';
import '../src/modules/activation/view/activation_screen.dart';
import '../src/modules/auth/view/login_screen.dart';
import '../src/modules/inactive/view/inactive_screen.dart';
import '../src/modules/shell/view/shell_screen.dart';
import '../src/modules/dashboard/view/dashboard_screen.dart';
import '../src/modules/approvals/view/approvals_screen.dart';
import '../src/modules/order/view/order_screen.dart';
import '../src/modules/cash_shift/view/cash_shift_screen.dart';
import '../src/modules/report/view/report_screen.dart';
import '../src/modules/user/view/user_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  AppRouter._();

  static const String splash = '/splash';
  static const String activation = '/activation';
  static const String inactive = '/inactive';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String approvals = '/approvals';
  static const String orders = '/orders';
  static const String cashShifts = '/cash-shifts';
  static const String reports = '/reports';
  static const String users = '/users';

  static GoRouter createRouter(
    AppSessionCubit sessionCubit, {
    String? initialLocation,
  }) {
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    final dashboardNavKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
    final approvalsNavKey = GlobalKey<NavigatorState>(debugLabel: 'approvals');
    final ordersNavKey = GlobalKey<NavigatorState>(debugLabel: 'orders');
    final cashShiftsNavKey = GlobalKey<NavigatorState>(debugLabel: 'cashShifts');
    final usersNavKey = GlobalKey<NavigatorState>(debugLabel: 'users');

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: initialLocation ?? splash,
      refreshListenable: GoRouterRefreshStream(sessionCubit.stream),
      redirect: (context, state) {
        final sessionState = sessionCubit.state;
        final currentLoc = state.matchedLocation;
        final isSplashing = currentLoc == splash;
        final isLoggingIn = currentLoc == login;
        final isActivating = currentLoc == activation;
        final isInactive = currentLoc == inactive;

        final isInitial = sessionState.status == AppSessionStatus.initial ||
            sessionState.status == AppSessionStatus.loading;

        // 1. Inicialización en progreso -> permanecer en /splash
        if (isInitial) {
          return isSplashing ? null : splash;
        }

        // 2. Instancia no activada -> Redirigir a /activation
        if (sessionState.status == AppSessionStatus.unactivated) {
          return isActivating ? null : activation;
        }

        // 3. Instancia inactiva / suspendida -> Redirigir a /inactive
        if (sessionState.status == AppSessionStatus.instanceInactive) {
          return isInactive ? null : inactive;
        }

        // 4. Usuario no autenticado -> Redirigir a /login
        if (!sessionState.isAuthenticated) {
          return isLoggingIn ? null : login;
        }

        // 5. Si ya está autenticado e intenta ir a splash, login, activación, inactivo o raíz -> dashboard
        if (isSplashing || isLoggingIn || isActivating || isInactive || currentLoc == '/') {
          return dashboard;
        }

        // 6. Restricción para no-administradores: aprobaciones y usuarios son exclusivos de admins
        if (!sessionState.isAdmin) {
          final isApprovals = currentLoc == approvals || currentLoc.startsWith('$approvals/');
          final isUsers = currentLoc == users || currentLoc.startsWith('$users/');
          if (isApprovals || isUsers) {
            return dashboard;
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: activation,
          builder: (context, state) => const ActivationScreen(),
        ),
        GoRoute(
          path: inactive,
          builder: (context, state) => const InactiveScreen(),
        ),
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: reports,
          builder: (context, state) => const ReportScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return ShellScreen(navigationShell: navigationShell);
          },
          branches: [
            // Branch 0: Dashboard
            StatefulShellBranch(
              navigatorKey: dashboardNavKey,
              routes: [
                GoRoute(
                  path: dashboard,
                  builder: (context, state) => const DashboardScreen(),
                ),
              ],
            ),
            // Branch 1: Approvals
            StatefulShellBranch(
              navigatorKey: approvalsNavKey,
              routes: [
                GoRoute(
                  path: approvals,
                  builder: (context, state) => const ApprovalsScreen(),
                ),
              ],
            ),
            // Branch 2: Orders
            StatefulShellBranch(
              navigatorKey: ordersNavKey,
              routes: [
                GoRoute(
                  path: orders,
                  builder: (context, state) => const OrderScreen(),
                ),
              ],
            ),
            // Branch 3: Cash Shifts
            StatefulShellBranch(
              navigatorKey: cashShiftsNavKey,
              routes: [
                GoRoute(
                  path: cashShifts,
                  builder: (context, state) => const CashShiftScreen(),
                ),
              ],
            ),
            // Branch 4: Users
            StatefulShellBranch(
              navigatorKey: usersNavKey,
              routes: [
                GoRoute(
                  path: users,
                  builder: (context, state) => const UserScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
