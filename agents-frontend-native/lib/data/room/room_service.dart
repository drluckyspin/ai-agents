import 'package:livekit_client/livekit_client.dart';

// TODO: This is in working phase, will be used later on
class RoomService {
  List<TranscriptionSegment> _sortedTranscriptions = [];
  late EventsListener<RoomEvent> _listener;
  final Map<String, TranscriptionSegment> _transcriptions = {};
  late Room _room;
  late final Stream<List<TranscriptionSegment>> stream;

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
        for (final segment in event.segments) {
          _transcriptions[segment.id] = segment;
        }
        // Sort transcriptions
        _sortedTranscriptions = _transcriptions.values.toList()
          ..sort((a, b) => a.firstReceivedTime.compareTo(b.firstReceivedTime));

        for (var element in _sortedTranscriptions) {
          print(element.text);
        }
      });
    } catch (error) {
      print('Could not connect $error');
    } finally {
      print('Finally reached!');
    }
  }

  EventsListenable<RoomEvent> getListener() {
    return _listener;
  }
}
