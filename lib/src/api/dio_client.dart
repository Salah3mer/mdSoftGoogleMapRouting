import 'package:dio/dio.dart';

class DioClient {
  Dio? dio;
  DioClient(
    Dio? dioC,
  ) {
    dio = dioC ?? Dio();

    dio!.options
      ..followRedirects = false
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 10);
  }

  Future<Response> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    var response = await dio!.get(
      uri,
      queryParameters: queryParameters,
      options: Options(
        headers: headers,
      ),
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
    return response;
  }

  Future<Response> post(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    var response = await dio!.post(
      uri,
      data: data,
      queryParameters: queryParameters,
      options: Options(
        headers: headers,
      ),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return response;
  }
}
