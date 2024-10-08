import 'dart:async';

import 'package:hp_live_kit/data/reporistory/livekit/room_constants.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../common/model/transcription_with_participant.dart';

class RoomService {
  final Map<String, TranscriptionWithParticipant> _transcriptions = {};
  late EventsListener<RoomEvent> _listener;
  late Room _room;

  final StreamController<List<TranscriptionWithParticipant>>
      _eventStreamController =
      StreamController<List<TranscriptionWithParticipant>>();

  Stream<List<TranscriptionWithParticipant>> get eventStream =>
      _eventStreamController.stream;

  Future<void> connect(
      String url, String token, LocalAudioTrack? audioTrack) async {
    try {
      _room = Room(
        roomOptions: const RoomOptions(
          defaultAudioPublishOptions: AudioPublishOptions(
            name: 'custom_audio_track_name',
          ),
        ),
      );

      // Create a Listener before connecting
      _listener = _room.createListener();

      await _room.prepareConnection(url, token);

      // Try to connect to the room
      // This will throw an Exception if it fails for any reason.
      await _room.connect(
        url,
        token,
        fastConnectOptions: FastConnectOptions(
          microphone: TrackOption(track: audioTrack),
        ),
      );

      // Transcription part
      _listener.on<TranscriptionEvent>((event) {
        final participant = event.participant is RemoteParticipant
            ? RoomConstants.botName
            : RoomConstants.userName;

        // Map transcription data and add participant name
        for (final segment in event.segments) {
          final oldTranscriptionData = _transcriptions[segment.id];
          final participantName =
              oldTranscriptionData?.participant ?? participant;
          _transcriptions[segment.id] = TranscriptionWithParticipant(
              transcriptionText: segment.text, participant: participantName);
        }

        // Send data via stream
        _eventStreamController.add(_transcriptions.values.toList());
      });
    } catch (error) {
      print('Could not connect $error');
    } finally {
      print('Finally reached!');
    }
  }

  Future<void> dispose() async {
    _eventStreamController.close();
    await _listener.dispose();
    await _room.dispose();
  }
}