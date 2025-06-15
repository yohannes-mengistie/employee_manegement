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
      return await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
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
      return await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
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
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiException('Connection timeout. Please try again.');
        
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['message'] ?? 'Unknown error occurred';
          
          switch (statusCode) {
            case 400:
              return ApiException('Bad request: $message');
            case 401:
              return ApiException('Unauthorized access. Please login again.');
            case 403:
              return ApiException('Access forbidden.');
            case 404:
              return ApiException('Resource not found.');
            case 500:
              return ApiException('Server error. Please try again later.');
            default:
              return ApiException('Error $statusCode: $message');
          }
        
        case DioExceptionType.cancel:
          return ApiException('Request was cancelled');
        
        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return ApiException('No internet connection');
          }
          return ApiException('Network error occurred');
        
        default:
          return ApiException('Unknown error occurred');
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
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
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
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR: ${err.response?.statusCode} ${err.requestOptions.path}');
    print('📝 Error: ${err.message}');
    handler.next(err);
  }
}

// Error Interceptor
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log error details for debugging
    print('API Error: ${err.message}');
    if (err.response != null) {
      print('Status Code: ${err.response!.statusCode}');
      print('Response Data: ${err.response!.data}');
    }
    handler.next(err);
  }
}
