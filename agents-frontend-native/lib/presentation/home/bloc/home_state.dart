import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:hp_live_kit/common/model/transcription_with_participant.dart';

@immutable
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class Initial extends HomeState {}

class Loading extends HomeState {}

class Success extends HomeState {}

class Error extends HomeState {
  final String errorMessage;

  const Error({required this.errorMessage});
}

class TranscriptionEvents extends HomeState {
  final List<TranscriptionWithParticipant> transcriptionEvents;

  const TranscriptionEvents({required this.transcriptionEvents});
}
