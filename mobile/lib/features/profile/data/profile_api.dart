import 'package:dio/dio.dart';

import '../domain/user_profile.dart';

class ProfileApi {
  final Dio _dio;

  ProfileApi({required Dio dio}) : _dio = dio;

  Future<UserProfile> getMyProfile() async {
    final response = await _dio.get('/auth/me');
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Invalid profile response format.',
      );
    }
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> updateMyProfile({
    required String email,
    required String name,
  }) async {
    final response = await _dio.put(
      '/auth/me',
      data: {
        'email': email,
        'name': name,
      },
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Invalid profile update response format.',
      );
    }
    return UserProfile.fromJson(data);
  }
}

