import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class ConnectEvent extends Equatable {
  const ConnectEvent();

  @override
  List<Object?> get props => [];
}

class ConnectRemotely extends ConnectEvent {
  final String serverURL;
  final String token;

  const ConnectRemotely({required this.serverURL, required this.token});
}
