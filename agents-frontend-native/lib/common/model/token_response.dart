import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class TokenResponse extends Equatable {
  final String token;

  const TokenResponse({
    required this.token,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) => TokenResponse(
        token: json["token"] as String,
      );

  @override
  List<Object?> get props => [
        token,
      ];
}
