import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class ConnectState extends Equatable {
  const ConnectState();

  @override
  List<Object?> get props => [];
}

class Initial extends ConnectState {}

class Loading extends ConnectState {}

class Success extends ConnectState {}

class Error extends ConnectState {
  final String errorMessage;

  const Error({required this.errorMessage});
}
