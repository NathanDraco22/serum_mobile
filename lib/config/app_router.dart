import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../src/cubits/app_session_cubit/app_session_cubit.dart';
import '../src/modules/auth/view/login_screen.dart';
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

  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String approvals = '/approvals';
  static const String orders = '/orders';
  static const String cashShifts = '/cash-shifts';
  static const String reports = '/reports';
  static const String users = '/users';

  static GoRouter createRouter(AppSessionCubit sessionCubit) {
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    final dashboardNavKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
    final approvalsNavKey = GlobalKey<NavigatorState>(debugLabel: 'approvals');
    final ordersNavKey = GlobalKey<NavigatorState>(debugLabel: 'orders');
    final cashShiftsNavKey = GlobalKey<NavigatorState>(debugLabel: 'cashShifts');
    final usersNavKey = GlobalKey<NavigatorState>(debugLabel: 'users');

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: dashboard,
      refreshListenable: GoRouterRefreshStream(sessionCubit.stream),
      redirect: (context, state) {
        final sessionState = sessionCubit.state;
        final isLoggingIn = state.matchedLocation == login;

        if (sessionState.status == AppSessionStatus.initial ||
            sessionState.status == AppSessionStatus.loading) {
          return null;
        }

        // Si no está autenticado, redirigir a Login
        if (!sessionState.isAuthenticated) {
          return isLoggingIn ? null : login;
        }

        // Si ya está autenticado e intenta ir al Login o raíz, llevar al Dashboard
        if (isLoggingIn || state.matchedLocation == '/') {
          return dashboard;
        }

        return null;
      },
      routes: [
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
