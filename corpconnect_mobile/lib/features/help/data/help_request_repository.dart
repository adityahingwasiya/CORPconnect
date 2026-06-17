import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

class HelpRequestRepository {
  HelpRequestRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  /// POST `/api/help-requests` with [helperEmployeeId] and [message].
  Future<void> sendHelpRequest(int helperId, String message) async {
    await _dio.post<Map<String, dynamic>>(
      '/api/help-requests',
      data: {
        'helperEmployeeId': helperId,
        'message': message,
      },
    );
  }
}
