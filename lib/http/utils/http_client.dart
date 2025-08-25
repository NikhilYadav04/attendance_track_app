import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../config/api_config.dart';

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  late Dio _dio;
  String? _authToken;

  //* Secure storage - automatically encrypted
  static const _secureStorage = FlutterSecureStorage();

  //* Storage keys
  static const String _authTokenKey = 'auth_token';

  Dio get dio => _dio;

  Future<void> init() async {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
      sendTimeout: Duration(milliseconds: ApiConfig.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    //* Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (kDebugMode) {
            print('REQUEST: ${options.method} ${options.uri}');
            print('HEADERS: ${options.headers}');
            print('DATA: ${options.data}');
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
                'RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
            print('DATA: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            print(
                'ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}');
            print('MESSAGE: ${error.message}');
          }

          handler.next(error);
        },
      ),
    );
  }

  //* ============ TOKEN METHODS ============

  //* Method 1: Store token in memory (simple but lost on app restart)
  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  //* Method 2: Store token in SecureStorage (persistent)
  Future<void> saveAuthToken(String token) async {
    _authToken = token;
    await _secureStorage.write(key: _authTokenKey, value: token);
  }

  Future<String?> getAuthToken() async {
    //* First check memory for fast access
    if (_authToken != null) return _authToken;

    //* If not in memory, check secure storage
    _authToken = await _secureStorage.read(key: _authTokenKey);
    return _authToken;
  }

  Future<void> removeAuthToken() async {
    _authToken = null;
    await _secureStorage.delete(key: _authTokenKey);
  }

  //* Method 4: Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();

    if (token == null || token.isEmpty) {
      return false;
    } else {
      Logger().d("Token is Valid ${token}");

      return true;
    }
  }

  //* Method 5: Logout - clear all tokens
  Future<void> logout() async {
    await removeAuthToken();
  }
}
