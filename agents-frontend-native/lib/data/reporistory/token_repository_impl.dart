import 'package:hp_live_kit/common/model/token_request.dart';
import 'package:hp_live_kit/common/model/token_response.dart';
import 'package:hp_live_kit/data/network/network_service.dart';
import 'package:hp_live_kit/data/reporistory/token_repository.dart';

final class TokenRepositoryImpl implements TokenRepository {
  final NetworkService _networkClient;

  TokenRepositoryImpl(this._networkClient);

  @override
  Future<TokenResponse> getToken(TokenRequest tokenRequest) async {
    const uri = 'https://tg.quickdeploys.com/getToken';
    final result = await _networkClient.post(uri, tokenRequest.toJson());
    return TokenResponse.fromJson(result);
  }
}
