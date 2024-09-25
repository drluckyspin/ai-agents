import 'package:hp_live_kit/common/model/token_response.dart';
import 'package:hp_live_kit/data/local/environment_params_service.dart';
import 'package:hp_live_kit/data/remote/network/endpoint_path.dart';
import 'package:hp_live_kit/data/remote/network/network_service.dart';
import 'package:hp_live_kit/data/reporistory/token/token_repository.dart';

final class TokenRepositoryImpl implements TokenRepository {
  final NetworkService _networkClient;
  final EnvironmentParamsService _environmentParamsService;

  TokenRepositoryImpl(this._networkClient, this._environmentParamsService);

  @override
  Future<TokenResponse> getToken() async {
    final tokenRequest = _environmentParamsService.getTokenRequestParams();
    final result = await _networkClient.post(
        EndpointPath.token.value, tokenRequest.toJson());
    return TokenResponse.fromJson(result);
  }
}
