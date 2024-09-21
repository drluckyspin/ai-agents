import 'dart:async';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hp_live_kit/presentation/theme/colors.dart';
import 'package:hp_live_kit/presentation/widgets/tab_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:livekit_client/livekit_client.dart';

import '../theme/dimen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String tabConversation = 'Conversation';
  static const String tabSummary = 'Summary';
  static const double micImageSize = 40.0;
  String selectedTab = tabConversation;

  List<MediaDevice> _audioInputs = [];
  StreamSubscription? _subscription;
  MediaDevice? _selectedAudioDevice;
  LocalAudioTrack? _audioTrack;
  bool _enableAudio = true;
  String logString = '';

  final url = 'wss://app1-rto76cus.livekit.cloud';
  final token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZGVudGl0eSI6IiIsIm5hbWUiOiJDb29sLUJhaW4tQ2xpZW50IiwidmlkZW8iOnsicm9vbUNyZWF0ZSI6ZmFsc2UsInJvb21MaXN0IjpmYWxzZSwicm9vbVJlY29yZCI6ZmFsc2UsInJvb21BZG1pbiI6ZmFsc2UsInJvb21Kb2luIjp0cnVlLCJyb29tIjoibXktcm9vbSIsImNhblB1Ymxpc2giOnRydWUsImNhblN1YnNjcmliZSI6dHJ1ZSwiY2FuUHVibGlzaERhdGEiOnRydWUsImNhblB1Ymxpc2hTb3VyY2VzIjpbXSwiY2FuVXBkYXRlT3duTWV0YWRhdGEiOmZhbHNlLCJpbmdyZXNzQWRtaW4iOmZhbHNlLCJoaWRkZW4iOmZhbHNlLCJyZWNvcmRlciI6ZmFsc2UsImFnZW50IjpmYWxzZX0sInNpcCI6eyJhZG1pbiI6ZmFsc2UsImNhbGwiOmZhbHNlfSwiYXR0cmlidXRlcyI6e30sIm1ldGFkYXRhIjoiIiwic2hhMjU2IjoiIiwic3ViIjoiQ29vbC1CYWluIiwiaXNzIjoiQVBJTHJHVkVFMzJ5N2h5IiwibmJmIjoxNzI2OTU1Mjc0LCJleHAiOjE3MjY5NzY4NzR9.VmLdIuZRTh_zG4voj6REfy5DhL5MChPACb6uoOZYVs0';

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      _checkPermissions();
    }

    _subscription =
        Hardware.instance.onDeviceChange.stream.listen(_loadDevices);
    Hardware.instance.enumerateDevices().then(_loadDevices);
  }

  @override
  void deactivate() {
    _subscription?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _loadDevices(List<MediaDevice> devices) async {
    _audioInputs = devices.where((d) => d.kind == 'audioinput').toList();

    if (_audioInputs.isNotEmpty) {
      if (_selectedAudioDevice == null) {
        _selectedAudioDevice = _audioInputs.first;
        Future.delayed(const Duration(milliseconds: 100), () async {
          await _changeLocalAudioTrack();
          setState(() {});
        });
      }
    }
    setState(() {});
  }

  Future<void> _setEnableAudio(value) async {
    _enableAudio = value;
    if (!_enableAudio) {
      await _audioTrack?.stop();
      _audioTrack = null;
    } else {
      await _changeLocalAudioTrack();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final micIconPath = _enableAudio
        ? 'assets/images/ic_microphone.svg'
        : 'assets/images/ic_microphone_muted.svg';
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            flexibleSpace: const Image(
              image: AssetImage('assets/images/img_hp_app_bar.png'),
              fit: BoxFit.cover,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(Dimen.spacingXl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TabView(
                        text: tabConversation,
                        isSelected: selectedTab == tabConversation,
                        onPressed: () =>
                            setState(() => selectedTab = tabConversation),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.0),
                        child: VerticalDivider(
                          color: tabDivider,
                          thickness: 2,
                        ),
                      ),
                      TabView(
                        text: tabSummary,
                        isSelected: selectedTab == tabSummary,
                        onPressed: () =>
                            setState(() => selectedTab = tabSummary),
                      ),
                      const Spacer(),
                      InkWell(
                          onTap: _onSettingsPressed,
                          child: SvgPicture.asset(
                              'assets/images/ic_settings.svg')),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: SvgPicture.asset('assets/images/img_audio_waves.svg'),
                ),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: _onMicPressed,
                        child: SvgPicture.asset(
                          micIconPath,
                          width: micImageSize,
                          height: micImageSize,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: Dimen.spacingXs),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: grayBorderColor,
                              style: BorderStyle.solid,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(Dimen.radius),
                          ),
                          child: Flex(
                            direction: Axis.vertical,
                            children: [
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<MediaDevice>(
                                    isExpanded: true,
                                    disabledHint:
                                        const Text('Disabled Microphone'),
                                    hint: const Text(
                                      'Select Microphone',
                                    ),
                                    items: _enableAudio
                                        ? _audioInputs
                                            .map((MediaDevice item) =>
                                                DropdownMenuItem<MediaDevice>(
                                                  value: item,
                                                  child: Text(
                                                    item.label,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ))
                                            .toList()
                                        : [],
                                    value: _selectedAudioDevice,
                                    onChanged: (MediaDevice? value) async {
                                      if (value != null) {
                                        _selectedAudioDevice = value;
                                        await _changeLocalAudioTrack();
                                        setState(() {});
                                      }
                                    },
                                    buttonStyleData: const ButtonStyleData(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      height: 35,
                                      width: 250,
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 35,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    style: const TextStyle(color: Colors.black),
                    logString,
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Container(
                      alignment: Alignment.topLeft,
                      color: Colors.black,
                      child: SingleChildScrollView(
                        child: Column(
                            children: _sortedTranscriptions
                                .map(
                                  (segment) => ListTile(
                                    title: Text(
                                      segment.text,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                                .toList()),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String textForTab(String tabId) {
    switch (tabId) {
      case tabConversation:
        return 'Conversations with agent.';
      case tabSummary:
        return 'Summary of all the chats.';
      default:
        return 'Select Tab';
    }
  }

  List<TranscriptionSegment> _sortedTranscriptions = [];
  late EventsListener<RoomEvent> _listener;
  Map<String, TranscriptionSegment> _transcriptions = {};

  void _onSettingsPressed() async {
    setState(() {});
    try {
      final room = Room(
        roomOptions: const RoomOptions(
          defaultAudioPublishOptions: AudioPublishOptions(
            name: 'custom_audio_track_name',
          ),
        ),
      );
      // Create a Listener before connecting
      _listener = room.createListener();

      await room.prepareConnection(url, token);

      // Try to connect to the room
      // This will throw an Exception if it fails for any reason.
      await room.connect(
        url,
        token,
        fastConnectOptions: FastConnectOptions(
          microphone: TrackOption(track: _audioTrack),
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

        setState(() {
          _transcriptions;
          _sortedTranscriptions;
        });
      });
    } catch (error) {
      print('Could not connect $error');
    } finally {
      setState(() {
        logString = 'Connected';
      });
    }
  }

  void _onMicPressed() {
    setState(() {
      _setEnableAudio(!_enableAudio);
    });
  }

  void _checkPermissions() async {
    final status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) {
      print('Microphone Permission disabled');
    }
  }

  Future<void> _changeLocalAudioTrack() async {
    if (_audioTrack != null) {
      await _audioTrack!.stop();
      _audioTrack = null;
    }

    if (_selectedAudioDevice != null) {
      _audioTrack = await LocalAudioTrack.create(AudioCaptureOptions(
        deviceId: _selectedAudioDevice!.deviceId,
      ));
      await _audioTrack!.start();
    }
  }
}
