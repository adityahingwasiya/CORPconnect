import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

class EmployeeRepository {
  EmployeeRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  /// GET `/api/employees/me/colleagues` with optional `?city=...`.
  Future<List<dynamic>> getColleagues({String? city}) async {
    final Map<String, dynamic>? queryParameters =
        (city != null && city.isNotEmpty) ? {'city': city} : null;

    final response = await _dio.get<dynamic>(
      '/api/employees/me/colleagues',
      queryParameters: queryParameters,
    );

    final data = response.data;
    if (data == null) {
      return [];
    }
    if (data is List) {
      return List<dynamic>.from(data);
    }
    throw FormatException(
      'Expected list of colleagues, got ${data.runtimeType}',
    );
  }

  /// PATCH `/api/employees/me/location` with new city.
  Future<void> updateLocation(String currentCity) async {
    await _dio.patch<dynamic>(
      '/api/employees/me/location',
      data: {'currentCity': currentCity},
    );
  }

  /// GET `/api/employees/company/{companyId}` — for company admins.
  Future<List<dynamic>> getEmployeesByCompany(int companyId) async {
    final response = await _dio.get<dynamic>(
      '/api/employees/company/$companyId',
    );

    final data = response.data;
    if (data == null) {
      return [];
    }
    if (data is List) {
      return List<dynamic>.from(data);
    }
    throw FormatException(
      'Expected list of employees, got ${data.runtimeType}',
    );
  }

  /// POST `/api/employees/create` — for company admins.
  Future<void> createEmployee({
    required int companyId,
    required String name,
    required String email,
    required String password,
    required String baseCity,
    String? phone,
    String role = 'EMPLOYEE',
  }) async {
    await _dio.post<dynamic>(
      '/api/employees/create',
      data: {
        'companyId': companyId,
        'name': name,
        'email': email,
        'password': password,
        'baseCity': baseCity,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'role': role,
      },
    );
  }
}
