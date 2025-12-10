import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_config.dart';
import '../navigation_service.dart';

class ApiClient {
  late Dio _dio;
  final _storage = const FlutterSecureStorage();
  
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConfig.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Add interceptors for authentication, logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add JWT token to all requests except login
          if (!options.path.contains('/auth/login')) {
            final token = await _storage.read(key: 'access_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          print('REQUEST DATA: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          print('RESPONSE DATA: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          print('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
          print('ERROR MESSAGE: ${e.message}');
          print('ERROR RESPONSE: ${e.response?.data}');
          
          // Handle 401 Unauthorized - token expired or invalid
          if (e.response?.statusCode == 401) {
            // Clear stored tokens
            await _storage.delete(key: 'access_token');
            await _storage.delete(key: 'user_data');
            
            // Navigate to login screen
            NavigationService.navigateToLogin();
            
            // Show error message
            NavigationService.showSnackBar(
              'Your session has expired. Please login again.',
              isError: true,
            );
          }
          
          return handler.next(e);
        },
      ),
    );
  }
  
  // GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // POST request
  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // PATCH request
  Future<Response> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // DELETE request
  Future<Response> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // Error handler
  String _handleError(DioException error) {
    String errorMessage = '';
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        // Try to extract detailed error message from response
        if (error.response?.data != null) {
          if (error.response!.data is Map) {
            final data = error.response!.data as Map;
            // Check for NestJS validation error format
            if (data['message'] != null) {
              if (data['message'] is List) {
                errorMessage = (data['message'] as List).join(', ');
              } else {
                errorMessage = data['message'].toString();
              }
            } else if (data['error'] != null) {
              errorMessage = data['error'].toString();
            } else {
              errorMessage = 'Server error: ${error.response?.statusCode}';
            }
          } else {
            errorMessage = error.response!.data.toString();
          }
        } else {
          errorMessage = 'Server error: ${error.response?.statusCode}';
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled';
        break;
      default:
        errorMessage = 'Network error. Please try again.';
    }
    
    return errorMessage;
  }
}
