import 'package:dio/dio.dart';

class AdminApi {
  final Dio _dio;

  AdminApi({required Dio dio}) : _dio = dio;

  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await _dio.get('/admin/users');
    final data = response.data;
    if (data is List) {
      return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getDevices() async {
    final response = await _dio.get('/admin/devices');
    final data = response.data;
    if (data is List) {
      return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    }
    return [];
  }

  Future<void> updateUserRole(int userId, String role) async {
    await _dio.put('/admin/users/$userId/role', queryParameters: {'role': role});
  }
}
