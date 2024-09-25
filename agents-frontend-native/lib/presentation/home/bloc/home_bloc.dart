import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hp_live_kit/data/reporistory/livekit/room_repository.dart';

import '../../../common/model/transcription_with_participant.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final RoomRepository _roomRepository;

  StreamSubscription? _transcriptionsStreamSubscription;

  HomeBloc(this._roomRepository) : super(Initial()) {
    on<RoomConnect>(_emitRoomConnect);
  }

  FutureOr<void> _emitRoomConnect(
      RoomConnect event, Emitter<HomeState> emit) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    // await _roomRepository.connect(_audioTrack);

    // Listen to transcription events
    try {
      _transcriptionsStreamSubscription = _roomRepository
          .getTranscriptionsStream()
          .listen((List<TranscriptionWithParticipant> events) {
        emit(TranscriptionEvents(transcriptionEvents: events));
      });
    } catch (e) {}
  }

  @override
  Future<void> close() {
    _transcriptionsStreamSubscription?.cancel();
    return super.close();
  }
}
