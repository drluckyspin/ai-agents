import 'package:dio/dio.dart';

import 'network_service.dart';

class NetworkServiceImpl implements NetworkService {
  final Dio _dio;

  NetworkServiceImpl(this._dio);


  @override
  Future<T> post<T, K>(String path, K body) async {
    final response = await _dio.post(path, data: body);
    return response.data as T;
  }
}
