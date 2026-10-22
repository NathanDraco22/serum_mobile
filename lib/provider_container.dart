import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_serum_config.dart';
import 'package:serum_mobile/config/service_locator.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';

class ProviderContainer extends StatelessWidget {
  const ProviderContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    SerumClient.initialize(AppSerumConfig());

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppSettingsRepository>.value(
          value: sl<AppSettingsRepository>(),
        ),
        RepositoryProvider<AuthRepository>.value(
          value: sl<AuthRepository>(),
        ),
        RepositoryProvider<ServinRepository>.value(
          value: sl<ServinRepository>(),
        ),
        RepositoryProvider<BranchesRepository>.value(
          value: sl<BranchesRepository>(),
        ),
        RepositoryProvider<UsersRepository>.value(
          value: sl<UsersRepository>(),
        ),
        RepositoryProvider<CashShiftsRepository>.value(
          value: sl<CashShiftsRepository>(),
        ),
        RepositoryProvider<RolesRepository>.value(
          value: sl<RolesRepository>(),
        ),
        RepositoryProvider<ReportsRepository>.value(
          value: sl<ReportsRepository>(),
        ),
        RepositoryProvider<OrdersRepository>.value(
          value: sl<OrdersRepository>(),
        ),
        RepositoryProvider<LabTestsRepository>.value(
          value: sl<LabTestsRepository>(),
        ),
        RepositoryProvider<PatientsRepository>.value(
          value: sl<PatientsRepository>(),
        ),
        RepositoryProvider<DoctorsRepository>.value(
          value: sl<DoctorsRepository>(),
        ),
      ],
      child: GlobalCubitProvider(
        child: child,
      ),
    );
  }
}

class GlobalCubitProvider extends StatelessWidget {
  const GlobalCubitProvider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppSessionCubit>(
          create: (ctx) => AppSessionCubit(
            authRepository: ctx.read<AuthRepository>(),
            branchesRepository: ctx.read<BranchesRepository>(),
            usersRepository: ctx.read<UsersRepository>(),
            servinRepository: ctx.read<ServinRepository>(),
          )..initSession(),
        ),
      ],
      child: child,
    );
  }
}
