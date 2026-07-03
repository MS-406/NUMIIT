import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_client.dart';

class BackendHealth {
  const BackendHealth({required this.status});

  final String status;

  factory BackendHealth.fromJson(Map<String, dynamic> json) {
    return BackendHealth(status: json['status']?.toString() ?? 'unknown');
  }
}

class ApiService {
  ApiService(this._client);

  final DioClient _client;

  Future<BackendHealth> getHealth() async {
    try {
      final response = await _client.dio.get('/health');
      if (response.data is Map<String, dynamic>) {
        return BackendHealth.fromJson(response.data as Map<String, dynamic>);
      }
      return const BackendHealth(status: 'down');
    } catch (e) {
      return const BackendHealth(status: 'down');
    }
  }

  Future<String> login(String email, String password) async {
    final response = await _client.dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return data['access_token'] as String;
  }

  Future<String> register(String name, String email, String password) async {
    final response = await _client.dio.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return data['access_token'] as String;
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _client.dio.get('/users/me');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uploadImage({
    required String filePath,
    List<int>? bytes,
    String? fileName,
    String mode = 'coin',
  }) async {
    MultipartFile multipartFile;
    if (bytes != null && fileName != null) {
      multipartFile = MultipartFile.fromBytes(bytes, filename: fileName);
    } else {
      multipartFile = await MultipartFile.fromFile(filePath);
    }

    final formData = FormData.fromMap({
      'file': multipartFile,
    });

    final response = await _client.dio.post(
      '/uploads',
      data: formData,
      queryParameters: {'mode': mode},
    );

    return response.data as Map<String, dynamic>;
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ApiService(dioClient);
});

final backendHealthProvider = FutureProvider<BackendHealth>((ref) async {
  return ref.watch(apiServiceProvider).getHealth();
});
