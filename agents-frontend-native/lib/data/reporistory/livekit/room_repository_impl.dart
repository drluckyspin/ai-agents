import 'package:hp_live_kit/data/remote/livekit/room_service.dart';
import 'package:hp_live_kit/data/reporistory/livekit/room_repository.dart';
import 'package:hp_live_kit/data/reporistory/token/token_repository.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../common/model/transcription_with_participant.dart';

final class RoomRepositoryImpl implements RoomRepository {
  final TokenRepository _tokenRepository;
  final RoomService _roomService;

  RoomRepositoryImpl(this._tokenRepository, this._roomService);

  @override
  Future<void> connect(LocalAudioTrack? localAudioTrack) async {
    final tokenResponse = await _tokenRepository.getToken();
    const url = 'wss://cool-platform-app-eocfexdr.livekit.cloud';
    _roomService.connect(url, tokenResponse.token, localAudioTrack);
  }

  @override
  Stream<List<TranscriptionWithParticipant>> getTranscriptionsStream() {
    return _roomService.eventStream;
  }

  @override
  Future<void> dispose() async {
    await _roomService.dispose();
  }
}
