import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../common/model/transcription_with_participant.dart';

@immutable
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class RoomConnect extends HomeEvent {
  const RoomConnect();
}

class TransactionsStream extends HomeEvent {
  final List<TranscriptionWithParticipant> transcriptions;

  const TransactionsStream(
    this.transcriptions,
  );

  @override
  List<Object?> get props => [
        transcriptions,
      ];
}
