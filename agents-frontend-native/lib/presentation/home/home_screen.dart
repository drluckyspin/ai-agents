import 'dart:async';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hp_live_kit/di/service_locator.dart';
import 'package:hp_live_kit/presentation/theme/colors.dart';
import 'package:hp_live_kit/presentation/theme/text_size.dart';
import 'package:hp_live_kit/presentation/widgets/chat_item.dart';
import 'package:hp_live_kit/presentation/widgets/tab_view.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

import '../router/primary_route.dart';
import '../settings/settings_controller.dart';
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
  bool _isUserScrollingUp = false;
  bool isFirstTIme = true;

  final ScrollController _scrollController = ScrollController();

  final url = 'wss://cool-platform-app-eocfexdr.livekit.cloud';

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      _checkPermissions();
    }

    _subscription =
        Hardware.instance.onDeviceChange.stream.listen(_loadDevices);
    Hardware.instance.enumerateDevices().then(_loadDevices);

    _scrollController.addListener(_onListViewScroll);
  }

  void _onListViewScroll() {
    // Check if user is scrolling away from the bottom
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      _isUserScrollingUp = true; // User scrolled up
    } else if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _isUserScrollingUp = false; // User scrolled back to the bottom
    }
  }

  @override
  void deactivate() {
    _subscription?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    (() async {
      await _listener.dispose();
      await _room.dispose();
    })();
    _scrollController.removeListener(_onListViewScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadDevices(List<MediaDevice> devices) async {
    _audioInputs = devices.where((d) => d.kind == 'audioinput').toList();

    if (_audioInputs.isNotEmpty) {
      if (_selectedAudioDevice == null) {
        if (_audioInputs.length > 1) {
          _selectedAudioDevice = _audioInputs[1];
        } else {
          _selectedAudioDevice = _audioInputs.first;
        }
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
    // For demo purpose, Connect initially to room
    if (isFirstTIme) {
      connect();
      isFirstTIme = false;
    }

    final micIconPath = _enableAudio
        ? 'assets/images/ic_microphone.svg'
        : 'assets/images/ic_microphone_muted.svg';

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: background,
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
                        onTap: () => _onSettingsPressed(context),
                        child:
                            SvgPicture.asset('assets/images/ic_settings.svg'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: Dimen.spacingXl),
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
                                                    fontSize: TextSize.body1,
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
                                  buttonStyleData: ButtonStyleData(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: Dimen.spacingL),
                                    height: 35,
                                    width: 250,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: grayBorderColor,
                                      ),
                                      color: Colors.white,
                                    ),
                                  ),
                                  iconStyleData: const IconStyleData(
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_outlined,
                                    ),
                                    iconSize: 20,
                                    iconEnabledColor: chevronDownColor,
                                    iconDisabledColor: chevronDownColor,
                                  ),
                                  dropdownStyleData: const DropdownStyleData(
                                      decoration:
                                          BoxDecoration(color: Colors.white)),
                                  menuItemStyleData: const MenuItemStyleData(
                                    height: 35,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Padding(
                    padding: const EdgeInsets.only(top: Dimen.spacingXl),
                    child: Container(
                      alignment: Alignment.topLeft,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.all(Radius.circular(Dimen.radius)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: Dimen.spacing10),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _sortedTranscriptions.length,
                          itemBuilder: (BuildContext context, position) {
                            final segment = _sortedTranscriptions[position];
                            return ChatItem(
                                participant: segment.id, text: segment.text);
                          },
                        ),
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
  final Map<String, TranscriptionSegment> _transcriptions = {};
  late Room _room;

  void _onSettingsPressed(BuildContext context) async {
    context.push(
      PrimaryRoute.settings.path,
      extra: _audioTrack,
    );
  }

  void connect() async {
    final token = await serviceLocator.get<SettingsController>().getToken('');
    setState(() {});
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
          microphone: TrackOption(track: _audioTrack),
        ),
      );

      // Transcription part
      _listener.on<TranscriptionEvent>((event) {
        for (final segment in event.segments) {
          _transcriptions[segment.id] = segment;
        }

        _sortedTranscriptions = _transcriptions.values.toList()
          ..sort((a, b) => a.firstReceivedTime.compareTo(b.firstReceivedTime));

        setState(() {
          _transcriptions;
          _sortedTranscriptions;
        });

        if (!_isUserScrollingUp) {
          _scrollToBottom();
        }
      });
    } catch (error) {
      print('Could not connect $error');
    } finally {
      setState(() {
        logString = 'Connected';
        print(logString);
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }
}

class TranscriptionSegmentWithParticipant {
  final TranscriptionSegment transcriptionSegment;
  final String participant;

  TranscriptionSegmentWithParticipant(
      {required this.transcriptionSegment, required this.participant});
}
