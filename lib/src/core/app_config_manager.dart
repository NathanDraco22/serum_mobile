import 'dart:convert';
import 'package:serum_business/serum_business.dart';

/// Gestor de configuración persistente local para Serum Mobile utilizando Hive.
/// Almacena las credenciales de instancia (Servin) y la sucursal activa.
class AppConfigManager with HiveService implements AppConfigStore {
  final _configBox = 'app_config_box';
  final _configKey = 'servin_config_key';
  final _branchKey = 'selected_branch_key';

  static final AppConfigManager _instance = AppConfigManager._internal();
  factory AppConfigManager() => _instance;
  AppConfigManager._internal();

  @override
  Future<void> setConfig(Map<String, dynamic> config) async {
    try {
      final jsonString = json.encode(config);
      final box = await getBox(_configBox);
      await box.put(_configKey, jsonString);
    } catch (_) {}
  }

  @override
  Future<Map<String, dynamic>?> getConfig() async {
    try {
      final box = await getBox(_configBox);
      final jsonString = box.get(_configKey);
      if (jsonString == null) return null;
      final config = json.decode(jsonString as String);
      return config as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearConfig() async {
    try {
      final box = await getBox(_configBox);
      await box.clear();
    } catch (_) {}
  }

  Future<void> saveSelectedBranchId(String branchId) async {
    try {
      final box = await getBox(_configBox);
      await box.put(_branchKey, branchId);
    } catch (_) {}
  }

  Future<String?> getSelectedBranchId() async {
    try {
      final box = await getBox(_configBox);
      final branchId = box.get(_branchKey);
      return branchId as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSelectedBranchId() async {
    try {
      final box = await getBox(_configBox);
      await box.delete(_branchKey);
    } catch (_) {}
  }
}
