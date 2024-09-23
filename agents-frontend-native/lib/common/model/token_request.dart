import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class TokenRequest extends Equatable {
  final String liveKitApiKey;
  final String liveKitApiSecret;
  final String identity;
  final String name;
  final String room;

  const TokenRequest(this.liveKitApiKey, this.liveKitApiSecret, this.identity,
      this.name, this.room);

  Map<String, dynamic> toJson() => {
        "LIVEKIT_API_KEY": liveKitApiKey,
        "LIVEKIT_API_SECRET": liveKitApiSecret,
        "identity": identity,
        "name": name,
        "room": room,
      };

  @override
  List<Object?> get props =>
      [liveKitApiKey, liveKitApiSecret, identity, name, room];
}
