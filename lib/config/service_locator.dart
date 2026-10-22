import 'package:get_it/get_it.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/src/core/app_config_manager.dart';

final sl = GetIt.instance;

/// Configuración de inyección de dependencias con GetIt.
Future<void> setupServiceLocator() async {
  // Almacenamiento seguro local
  sl.registerLazySingleton<TokenStorage>(() => HiveTokenStorage());
  sl.registerLazySingleton<AppConfigStore>(() => AppConfigManager());

  // DataSources
  sl.registerLazySingleton<AppSettingsDataSource>(() => AppSettingsDataSource());
  sl.registerLazySingleton<AuthsDataSource>(() => AuthsDataSource());
  sl.registerLazySingleton<ServinDataSource>(() => ServinDataSource());
  sl.registerLazySingleton<UsersDataSource>(() => UsersDataSource());
  sl.registerLazySingleton<BranchesDataSource>(() => BranchesDataSource());
  sl.registerLazySingleton<CashShiftsDataSource>(() => CashShiftsDataSource());
  sl.registerLazySingleton<RolesDataSource>(() => RolesDataSource());
  sl.registerLazySingleton<ReportsDataSource>(() => ReportsDataSource());
  sl.registerLazySingleton<OrdersDataSource>(() => OrdersDataSource());
  sl.registerLazySingleton<LabTestsDataSource>(() => LabTestsDataSource());
  sl.registerLazySingleton<PatientsDataSource>(() => PatientsDataSource());
  sl.registerLazySingleton<DoctorsDataSource>(() => DoctorsDataSource());

  // Repositorios
  sl.registerLazySingleton<AppSettingsRepository>(
    () => AppSettingsRepository(sl<AppSettingsDataSource>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      dataSource: sl<AuthsDataSource>(),
      tokenStorage: sl<TokenStorage>(),
    ),
  );
  sl.registerLazySingleton<ServinRepository>(
    () => ServinRepository(
      servinDataSource: sl<ServinDataSource>(),
      appConfigStore: sl<AppConfigStore>(),
    ),
  );
  sl.registerLazySingleton<BranchesRepository>(
    () => BranchesRepository(sl<BranchesDataSource>()),
  );
  sl.registerLazySingleton<UsersRepository>(
    () => UsersRepository(sl<UsersDataSource>()),
  );
  sl.registerLazySingleton<CashShiftsRepository>(
    () => CashShiftsRepository(sl<CashShiftsDataSource>()),
  );
  sl.registerLazySingleton<RolesRepository>(
    () => RolesRepository(sl<RolesDataSource>()),
  );
  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepository(sl<ReportsDataSource>()),
  );
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepository(sl<OrdersDataSource>()),
  );
  sl.registerLazySingleton<LabTestsRepository>(
    () => LabTestsRepository(sl<LabTestsDataSource>()),
  );
  sl.registerLazySingleton<PatientsRepository>(
    () => PatientsRepository(sl<PatientsDataSource>()),
  );
  sl.registerLazySingleton<DoctorsRepository>(
    () => DoctorsRepository(sl<DoctorsDataSource>()),
  );
}
