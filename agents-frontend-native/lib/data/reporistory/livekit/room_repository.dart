import 'package:livekit_client/livekit_client.dart';

import '../../../common/model/transcription_with_participant.dart';
import '../../remote/livekit/room_service.dart';

abstract interface class RoomRepository {
  Future<void> connect(LocalAudioTrack? localAudioTrack);

  Stream<List<TranscriptionWithParticipant>> getTranscriptionsStream();

  Future<void> dispose();
}
