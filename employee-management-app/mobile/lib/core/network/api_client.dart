import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../storage/secure_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(this._storage)
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.readToken();
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (error, handler) {
        final message = error.response?.data is Map
            ? error.response?.data['message']?.toString()
            : error.message;
        handler.reject(DioException(
          requestOptions: error.requestOptions,
          response: error.response,
          error: ApiException(message ?? 'Network request failed', error.response?.statusCode),
        ));
      },
    ));
  }

  final Dio _dio;
  final SecureStorage _storage;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) => _unwrap(_dio.get(path, queryParameters: query));
  Future<dynamic> post(String path, {dynamic data}) => _unwrap(_dio.post(path, data: data));
  Future<dynamic> put(String path, {dynamic data}) => _unwrap(_dio.put(path, data: data));
  Future<dynamic> delete(String path) => _unwrap(_dio.delete(path));
  Future<dynamic> multipart(String path, FormData data) => _unwrap(_dio.post(path, data: data));

  Future<dynamic> _unwrap(Future<Response<dynamic>> request) async {
    try {
      final response = await request;
      return response.data is Map && response.data['data'] != null ? response.data['data'] : response.data;
    } on DioException catch (error) {
      if (error.error is ApiException) throw error.error as ApiException;
      throw ApiException(error.message ?? 'Network request failed', error.response?.statusCode);
    }
  }
}
