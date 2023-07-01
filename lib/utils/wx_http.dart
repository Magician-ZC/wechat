import 'package:dio/dio.dart';

import 'index.dart';

///微信http
class WxHttpUtil {
  static final WxHttpUtil _instance = WxHttpUtil._internal();
  factory WxHttpUtil() => _instance;
  Dio? _dio;

  WxHttpUtil._internal() {
    if (_dio == null) {
      _dio = Dio();
      _dio?.options = BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 5),
          headers: {},
          contentType: 'application/json; charset=utf-8',
          responseType: ResponseType.json);
    }
  }

  ///get请求
  Future<Response> get(String url, {Map<String, dynamic>? data}) async {
    Response response = await _dio!.get(url, queryParameters: data);
    return response;
  }

  ///post请求
  Future<Response> post(String url, {Map<String, dynamic>? data}) async {
    Response response = await _dio!.post(url, data: data);
    return response;
  }
}
