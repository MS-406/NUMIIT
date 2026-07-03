import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Default port the FastAPI backend runs on.
const int _defaultPort = 8000;

/// Returns the effective API base URL depending on the runtime platform.
///
/// Priority order:
/// 1. Compile-time `--dart-define=NUMIIT_API_BASE_URL=http://...`
/// 2. Platform-specific defaults:
///    - Web: same-origin `/api/v1`
///    - Android: `http://10.0.2.2:8000/api/v1` (emulator → host loopback)
///    - iOS / Desktop: `http://127.0.0.1:8000/api/v1`
///
/// For physical Android/iOS device testing, pass your laptop's WiFi IP:
///   `flutter run --dart-define=NUMIIT_API_BASE_URL=http://192.168.x.x:8000/api/v1`
String getEffectiveBaseUrl() {
  const envUrl = String.fromEnvironment(
    'NUMIIT_API_BASE_URL',
    defaultValue: '',
  );

  // If an explicit full URL was passed via --dart-define, use it as-is.
  if (envUrl.isNotEmpty &&
      (envUrl.startsWith('http://') || envUrl.startsWith('https://'))) {
    return envUrl;
  }

  // ----- Web: resolve relative to the page origin -----
  if (kIsWeb) {
    const apiPath = '/api/v1';
    if (kDebugMode) {
      if (Uri.base.host.endsWith('github.dev')) {
        final host = Uri.base.host.replaceFirst(RegExp(r'-\d+\.'), '-8000.');
        return '${Uri.base.scheme}://$host$apiPath';
      }
      return 'http://localhost:8000$apiPath';
    }
    final baseUri = Uri.base;
    final portPart = baseUri.hasPort ? ':${baseUri.port}' : '';
    final origin = '${baseUri.scheme}://${baseUri.host}$portPart';
    return '$origin$apiPath';
  }

  // ----- Native (Android / iOS / Desktop) -----
  // Android emulator maps 10.0.2.2 → host machine's 127.0.0.1.
  // Everything else can reach localhost directly.
  final isAndroid = defaultTargetPlatform == TargetPlatform.android;
  final host = isAndroid ? '10.0.2.2' : '127.0.0.1';
  return 'http://$host:$_defaultPort/api/v1';
}

class DioClient {
  DioClient() {
    final baseUrl = getEffectiveBaseUrl();
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach JWT token from SharedPreferences if available.
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            print('API Request: ${options.method} ${options.uri}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('API Response: ${response.statusCode} for ${response.requestOptions.uri}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print('API Error: ${e.response?.statusCode} ${e.message} for ${e.requestOptions.uri}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  late final Dio _dio;

  Dio get dio => _dio;
}

final dioClientProvider = Provider<DioClient>((ref) => DioClient());
