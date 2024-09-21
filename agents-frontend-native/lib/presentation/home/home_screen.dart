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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Container(
                      alignment: Alignment.topLeft,
                      color: Colors.black,
                      child: Text(
                        style: const TextStyle(color: Colors.white),
                        textForTab(selectedTab),
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

  void _onSettingsPressed() {
    // TODO: Not Implemented
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
