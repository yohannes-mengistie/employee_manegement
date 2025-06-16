import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:employee_manegement/core/config/api_config.dart';
import 'package:employee_manegement/core/exceptions/api_exceptions.dart';
import 'package:employee_manegement/core/services/token_service.dart';


class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  final TokenService _tokenService = TokenService();

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: ApiConfig.defaultHeaders,
    ));

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor(_tokenService));
    _dio.interceptors.add(_LoggingInterceptor());
    _dio.interceptors.add(_ErrorInterceptor());
  }

  // GET request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      print('🌐 Making GET request to: ${ApiConfig.baseUrl}$endpoint');
      return await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      print('❌ GET request failed: $e');
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      print('🌐 Making POST request to: ${ApiConfig.baseUrl}$endpoint');
      return await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      print('❌ POST request failed: $e');
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<Response> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }


  ApiException _handleError(dynamic error) {
    if (error is DioException) {
      print('🔍 DioException details:');
      print('  Type: ${error.type}');
      print('  Message: ${error.message}');
      print('  Response: ${error.response?.data}');
      print('  Status Code: ${error.response?.statusCode}');
      
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const ApiException('Connection timeout. Please check your internet connection.');
        
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;
          String message = 'Unknown error occurred';
          
          if (responseData is Map<String, dynamic>) {
            message = responseData['message'] ?? 
                     responseData['error'] ?? 
                     responseData['detail'] ?? 
                     'Server error occurred';
          } else if (responseData is String) {
            message = responseData;
          }
          
          switch (statusCode) {
            case 400:
              return ApiException('Bad request: $message');
            case 401:
              return const ApiException('Unauthorized access. Please login again.');
            case 403:
              return const ApiException('Access forbidden.');
            case 404:
              return const ApiException('Resource not found.');
            case 422:
              return ApiException('Validation failed: $message');
            case 500:
              return const ApiException('Server error. Please try again later.');
            default:
              return ApiException('Error $statusCode: $message');
          }
        
        case DioExceptionType.cancel:
          return const ApiException('Request was cancelled');
        
        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return const ApiException('No internet connection');
          }
          return const ApiException('Network error occurred');
        
        default:
          return const ApiException('Unknown error occurred');
      }
    }
    
    return ApiException('Unexpected error: ${error.toString()}');
  }
}

// Auth Interceptor for adding token to requests
class _AuthInterceptor extends Interceptor {
  final TokenService _tokenService;

  _AuthInterceptor(this._tokenService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip auth for login and refresh endpoints
    if (options.path.contains('/auth/login') || 
        options.path.contains('/auth/refresh')) {
      handler.next(options);
      return;
    }

    final token = await _tokenService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      print('🔑 Added auth token to request');
    } else {
      print('⚠️ No auth token available');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      print('🔄 Token expired, attempting refresh...');
      // Token expired, try to refresh
      final refreshed = await _tokenService.refreshToken();
      if (refreshed) {
        // Retry the original request
        final token = await _tokenService.getToken();
        if (token != null) {
          err.requestOptions.headers['Authorization'] = 'Bearer $token';
          final dio = Dio();
          try {
            final response = await dio.fetch(err.requestOptions);
            handler.resolve(response);
            return;
          } catch (e) {
            // If retry fails, continue with original error
          }
        }
      }
      
      // If refresh failed, clear tokens and redirect to login
      await _tokenService.clearTokens();
    }
    
    handler.next(err);
  }
}


// Logging Interceptor
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🚀 REQUEST: ${options.method} ${options.path}');
    print('📝 Data: ${options.data}');
    print('🔗 Headers: ${options.headers}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
    print('📦 Response Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR: ${err.response?.statusCode} ${err.requestOptions.path}');
    print('📝 Error: ${err.message}');
    print('📦 Error Response: ${err.response?.data}');
    handler.next(err);
  }
}

// Error Interceptor
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log error details for debugging
    print('API Error Details:');
    print('  URL: ${err.requestOptions.uri}');
    print('  Method: ${err.requestOptions.method}');
    print('  Status Code: ${err.response?.statusCode}');
    print('  Response Data: ${err.response?.data}');
    print('  Error Message: ${err.message}');
    handler.next(err);
  }
}
