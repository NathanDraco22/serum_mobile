import 'package:serum_business/serum_business.dart';

/// Configuración central de cliente de red y sesión para Serum Mobile.
class AppSerumConfig implements SerumClientConfig {
  static final AppSerumConfig _instance = AppSerumConfig._();
  factory AppSerumConfig() => _instance;
  AppSerumConfig._();

  static const _defaultBaseUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: 'http://localhost:8000',
  );

  String _baseUrl = _defaultBaseUrl;
  String _token = '';
  String? _branchId;
  String? _servinNickname;

  @override
  String get baseUrl => _baseUrl;

  void setBaseUrl(String url) {
    _baseUrl = url;
  }

  @override
  String get authToken => _token;

  @override
  set authToken(String token) {
    _token = token;
  }

  @override
  String? get branchId => _branchId;

  @override
  set branchId(String? id) {
    _branchId = id;
  }

  void setBranchId(String? id) {
    _branchId = id;
  }

  @override
  String? get servinNickname => _servinNickname;

  @override
  set servinNickname(String? nickname) {
    _servinNickname = nickname;
  }
}
