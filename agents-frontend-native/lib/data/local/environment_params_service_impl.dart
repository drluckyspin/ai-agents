import 'package:hp_live_kit/common/model/token_request.dart';
import 'package:hp_live_kit/data/local/environment_params_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';

class EnvironmentParamsServiceImpl implements EnvironmentParamsService {
  @override
  Future<void> initialize() async {
    dotenv.load(fileName: ".env");
  }

  @override
  String getLivekitServerUrl() {
    final String? serverUrl = dotenv.env['LIVEKIT_URL'];
    return serverUrl ?? '';
  }

  @override
  TokenRequest getTokenRequestParams() {
    final String livekitApiKey = dotenv.env['LIVEKIT_API_KEY'] ?? '';
    final String livekitApiSecret = dotenv.env['LIVEKIT_API_SECRET'] ?? '';
    final String identity = dotenv.env['IDENTITY'] ?? '';
    final String name = dotenv.env['NAME'] ?? '';

    final uuid = const Uuid().v4();
    final roomName = 'Flutter-$uuid';

    return TokenRequest(
        livekitApiKey, livekitApiSecret, identity, name, roomName);
  }
}
