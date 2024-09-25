import 'package:hp_live_kit/common/model/token_request.dart';
import 'package:hp_live_kit/common/model/token_response.dart';
import 'package:hp_live_kit/data/remote/network/endpoint_path.dart';
import 'package:hp_live_kit/data/remote/network/network_service.dart';
import 'package:hp_live_kit/data/reporistory/token/token_repository.dart';
import 'package:uuid/uuid.dart';

final class TokenRepositoryImpl implements TokenRepository {
  final NetworkService _networkClient;

  TokenRepositoryImpl(this._networkClient);

  @override
  Future<TokenResponse> getToken() async {
    final uuid = const Uuid().v4();

    final tokenRequest = TokenRequest(
        'APID4BNCFh7rdTX',
        'eUrvti3Le5S14regOz846FBmF9UImn8x1IQQlRvcgUgB',
        'HP-COOL',
        'Ivan Panic',
        'Flutter-$uuid');

    final result = await _networkClient.post(
        EndpointPath.token.value, tokenRequest.toJson());
    return TokenResponse.fromJson(result);
  }
}
