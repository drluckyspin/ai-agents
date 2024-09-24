import 'package:hp_live_kit/common/model/token_request.dart';
import 'package:hp_live_kit/common/model/token_response.dart';
import 'package:hp_live_kit/data/remote/livekit/room_service.dart';
import 'package:hp_live_kit/data/remote/network/endpoint_path.dart';
import 'package:hp_live_kit/data/remote/network/network_service.dart';
import 'package:hp_live_kit/data/reporistory/livekit/room_repository.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:uuid/uuid.dart';

final class RoomRepositoryImpl implements RoomRepository {
  final NetworkService _networkClient;
  final RoomService _roomService;

  RoomRepositoryImpl(this._networkClient, this._roomService);

  @override
  Future<void> connect(LocalAudioTrack? localAudioTrack) async {
    final tokenResponse = await getToken();
    const url = 'wss://cool-platform-app-eocfexdr.livekit.cloud';
    _roomService.connect(url, tokenResponse.token, localAudioTrack);
  }

  Future<TokenResponse> getToken() async {
    final uuid = const Uuid().v4();

    final tokenRequest = TokenRequest(
        "APID4BNCFh7rdTX",
        "eUrvti3Le5S14regOz846FBmF9UImn8x1IQQlRvcgUgB",
        "HP-COOL",
        "Ivan Panic",
        "Flutter-$uuid");

    final result = await _networkClient.post(
        EndpointPath.token.value, tokenRequest.toJson());

    return TokenResponse.fromJson(result);
  }

  @override
  Stream<List<TranscriptionSegmentWithParticipant>> getTranscriptionsStream() {
    return _roomService.eventStream;
  }

  @override
  Future<void> dispose() async {
    await _roomService.dispose();
  }
}
