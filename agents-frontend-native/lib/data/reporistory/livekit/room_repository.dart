import 'package:livekit_client/livekit_client.dart';

import '../../remote/livekit/room_service.dart';

abstract interface class RoomRepository {
  Future<void> connect(LocalAudioTrack? localAudioTrack);

  Stream<List<TranscriptionSegmentWithParticipant>> getTranscriptionsStream();

  Future<void> dispose();
}
