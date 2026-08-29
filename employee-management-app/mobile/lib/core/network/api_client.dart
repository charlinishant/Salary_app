import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../session/app_session.dart';
import '../storage/secure_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(this._storage)
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.baseUrl = ApiConfig.baseUrl;
        final token = await _storage.readToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Development mode headers
        options.headers.addAll(AppSession.instance.headers);

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

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) => _executeWithFailover((d) => d.get(path, queryParameters: query));
  Future<dynamic> post(String path, {dynamic data}) => _executeWithFailover((d) => d.post(path, data: data));
  Future<dynamic> put(String path, {dynamic data}) => _executeWithFailover((d) => d.put(path, data: data));
  Future<dynamic> patch(String path, {dynamic data}) => _executeWithFailover((d) => d.patch(path, data: data));
  Future<dynamic> delete(String path) => _executeWithFailover((d) => d.delete(path));
  Future<dynamic> multipart(String path, FormData data) => _executeWithFailover((d) => d.post(path, data: data));

  Future<dynamic> _executeWithFailover(Future<Response<dynamic>> Function(Dio dio) requestFn) async {
    for (int i = 0; i < ApiConfig.candidateUrls.length; i++) {
      final candidate = ApiConfig.candidateUrls[i];
      try {
        ApiConfig.setActiveBaseUrl(candidate);
        _dio.options.baseUrl = candidate;
        final response = await requestFn(_dio);
        return response.data;
      } on DioException catch (dioErr) {
        final isNetworkErr = dioErr.type == DioExceptionType.connectionTimeout ||
            dioErr.type == DioExceptionType.connectionError ||
            (dioErr.message?.contains('Connection refused') ?? false) ||
            (dioErr.message?.contains('SocketException') ?? false);

        // If it's a network/connection error and we have more candidate URLs to try, continue to next
        if (isNetworkErr && i < ApiConfig.candidateUrls.length - 1) {
          continue;
        }

        if (dioErr.error is ApiException) throw dioErr.error as ApiException;
        throw ApiException(dioErr.message ?? 'Network request failed', dioErr.response?.statusCode);
      } catch (e) {
        if (i < ApiConfig.candidateUrls.length - 1) {
          continue;
        }
        rethrow;
      }
    }
  }
}
