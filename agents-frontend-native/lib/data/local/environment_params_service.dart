import 'package:hp_live_kit/common/model/token_request.dart';

abstract interface class EnvironmentParamsService {
  Future<void> initialize();

  TokenRequest getTokenRequestParams();

  String getLivekitServerUrl();
}
