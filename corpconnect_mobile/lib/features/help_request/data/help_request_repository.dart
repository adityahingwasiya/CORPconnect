import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

class HelpRequestRepository {
  HelpRequestRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<void> sendHelpRequest(int helperId, String message) async {
    await _dio.post<Map<String, dynamic>>(
      '/api/help-requests',
      data: {
        'helperEmployeeId': helperId,
        'message': message,
      },
    );
  }

  Future<List<dynamic>> getAssignedRequests() async {
    final response = await _dio.get<dynamic>(
      '/api/help-requests/assigned-to-me',
    );

    final data = response.data;
    if (data == null) {
      return [];
    }
    if (data is List) {
      return List<dynamic>.from(data);
    }
    throw FormatException(
      'Expected list of help requests, got ${data.runtimeType}',
    );
  }

  Future<void> acceptRequest(int requestId) async {
    await _dio.patch<void>('/api/help-requests/$requestId/accept');
  }

  Future<void> resolveRequest(int requestId) async {
    await _dio.patch<void>('/api/help-requests/$requestId/resolve');
  }

  Future<List<dynamic>> getMyRequests() async {
    final response = await _dio.get<dynamic>(
      '/api/help-requests/my-requests',
    );

    final data = response.data;
    if (data == null) {
      return [];
    }
    if (data is List) {
      return List<dynamic>.from(data);
    }
    throw FormatException(
      'Expected list of help requests, got ${data.runtimeType}',
    );
  }
}

