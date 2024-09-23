abstract class NetworkService {
  Future<T> post<T, K>(String path, K body);
}
