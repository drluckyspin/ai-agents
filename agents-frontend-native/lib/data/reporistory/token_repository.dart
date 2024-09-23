import 'package:hp_live_kit/common/model/token_request.dart';
import 'package:hp_live_kit/common/model/token_response.dart';

abstract interface class TokenRepository {
  Future<TokenResponse> getToken(TokenRequest tokenRequest);
}
