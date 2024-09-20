import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hp_live_kit/presentation/theme/colors.dart';
import 'package:hp_live_kit/presentation/theme/text_size.dart';
import 'package:hp_live_kit/presentation/widgets/tab_view.dart';
import 'package:permission_handler/permission_handler.dart';

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
  bool isMicMuted = false;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      _checkPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final micIconPath = isMicMuted
        ? 'assets/images/ic_microphone_muted.svg'
        : 'assets/images/ic_microphone.svg';
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
                          child: const Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(Dimen.spacingS),
                                child: Text(
                                  'Main microphone',
                                  style: TextStyle(
                                      fontSize: TextSize.body1,
                                      fontWeight: FontWeight.w400,
                                      color: grayMicrophoneInUse),
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down_outlined,
                                  color: chevronDownColor),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      textForTab(selectedTab),
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
    // TODO: For now it will just change image
    setState(() {
      isMicMuted = !isMicMuted;
    });
  }

  void _checkPermissions() async {
    final status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) {
      print('Microphone Permission disabled');
    }
  }
}
