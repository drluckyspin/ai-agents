import 'dart:math';

import 'package:hp_live_kit/data/reporistory/token/token_repository.dart';

class HomeController {
  final TokenRepository _tokenRepository;

  HomeController(this._tokenRepository);

  Future<String> getToken(String serverUrl) async {
    final response = await _tokenRepository.getToken();
    return response.token;
  }
}
