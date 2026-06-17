import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/role_storage.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/storage/user_storage.dart';
import '../domain/login_type.dart';

class AuthRepository {
  AuthRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  /// [loginType] selects employee vs company admin API and expected role in response.
  Future<void> login(
    String email,
    String password,
    LoginType loginType,
  ) async {
    final path = switch (loginType) {
      LoginType.employee => '/api/auth/employee/login',
      LoginType.companyAdmin => '/api/auth/company/login',
    };

    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: {'email': email, 'password': password},
    );

    final data = response.data;
    if (data == null) {
      throw const FormatException('Login response missing body');
    }

    final token = _stringField(data, 'token');
    if (token == null || token.isEmpty) {
      throw const FormatException('Login response missing token');
    }

    final role = _stringField(data, 'role');
    if (role == null || role.isEmpty) {
      throw const FormatException('Login response missing role');
    }

    await TokenStorage.instance.saveToken(token);
    await RoleStorage.instance.saveRole(role);

    // Store user profile data from the login response
    if (loginType == LoginType.employee) {
      await UserStorage.instance.saveEmployeeData(
        name: _stringField(data, 'name') ?? '',
        email: _stringField(data, 'email') ?? email,
        userId: _intField(data, 'userId') ?? 0,
        currentCity: _stringField(data, 'currentCity') ?? '',
        baseCity: _stringField(data, 'baseCity') ?? '',
      );
    } else {
      await UserStorage.instance.saveCompanyData(
        companyName: _stringField(data, 'companyName') ?? '',
        userId: _intField(data, 'userId') ?? 0,
      );
    }
  }

  Future<void> logout() async {
    await TokenStorage.instance.clearToken();
    await RoleStorage.instance.clearRole();
    await UserStorage.instance.clear();
  }

  String? _stringField(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  int? _intField(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }
}
