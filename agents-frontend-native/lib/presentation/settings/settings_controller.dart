import 'dart:math';

import 'package:hp_live_kit/common/model/token_request.dart';
import 'package:hp_live_kit/data/reporistory/token_repository.dart';

class SettingsController {
  final TokenRepository _tokenRepository;

  SettingsController(this._tokenRepository);

  Future<String> getToken(String serverUrl) async {
    var randomNumberGenerator = Random();
    final randomNumber = randomNumberGenerator.nextInt(1000000).toString();

    final tokenRequest = TokenRequest(
        "APID4BNCFh7rdTX",
        "eUrvti3Le5S14regOz846FBmF9UImn8x1IQQlRvcgUgB",
        "HP-COOL",
        "Ivan Panic",
        "Flutter-${randomNumber}");
    final response = await _tokenRepository.getToken(tokenRequest);
    return response.token;
  }
}
