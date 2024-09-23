import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hp_live_kit/data/room/room_service.dart';
import 'package:hp_live_kit/presentation/settings/settings_controller.dart';
import 'package:hp_live_kit/presentation/theme/colors.dart';
import 'package:hp_live_kit/presentation/theme/text_size.dart';
import 'package:hp_live_kit/presentation/widgets/text_input_field.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../di/service_locator.dart';

import '../theme/dimen.dart';

enum ConnectionStatus { initial, loading, connected }

class SettingsScreen extends StatefulWidget {
  final LocalAudioTrack? localAudioTrack;

  SettingsScreen({super.key, this.localAudioTrack});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _serverURLTextController = TextEditingController(
      text: 'wss://cool-platform-app-eocfexdr.livekit.cloud');
  ConnectionStatus _connectionStatus = ConnectionStatus.initial;

  @override
  Widget build(BuildContext context) {
    final connectionIcon = _getConnectionIconBasedOnState();
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Settings & Connections',
          style: TextStyle(fontSize: 21.0, fontWeight: FontWeight.w400),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.chevron_left),
              // Put icon of your preference.
              onPressed: () {
                context.pop();
              },
            );
          },
        ),
        shape: const Border(
          bottom: BorderSide(color: settingsDivider, width: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bain Playground allows you to test your LiveKit Agent interaction by connecting your LiveKit Cloud of self-hosted instance.',
              style: TextStyle(
                  color: chatMessageText,
                  fontWeight: FontWeight.w300,
                  fontSize: 17.0),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                children: [
                  const Text(
                    'Server URL',
                    style: TextStyle(color: grayMicrophoneInUse),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: HPTextInputField(
                        label: 'Server URL',
                        textEditingController: _serverURLTextController,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _onConnectPressed(context),
                    child: Icon(connectionIcon),
                  ),
                ],
              ),
            ),
            devicesWidget(context),
          ],
        ),
      ),
    );
  }

  void _onConnectPressed(BuildContext context) async {
    if (_connectionStatus == ConnectionStatus.initial) {
      _connectionStatus = ConnectionStatus.loading;
      setState(() {
        _connectionStatus;
      });
      final token = await serviceLocator.get<SettingsController>().getToken('');
      await serviceLocator.get<RoomService>().connect(
          'wss://cool-platform-app-eocfexdr.livekit.cloud',
          token,
          widget.localAudioTrack);
      _connectionStatus = ConnectionStatus.connected;
      setState(() {});
    }
  }

  Widget devicesWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimen.spacingXl),
      child: Container(
        alignment: Alignment.topLeft,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(Dimen.radius)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Dimen.spacing10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 13.0),
                child: Text(
                  'My Devices',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: 1,
                itemBuilder: (BuildContext context, position) {
                  final connectionColor = _getConnectionColor();
                  final connectionText = _getConnectionText();
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: grayBorderColor,
                      ),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          const Text(
                            'Cool-Room-1',
                            style: TextStyle(
                                color: chatMessageText,
                                fontSize: TextSize.chatTextSize,
                                fontWeight: FontWeight.w400),
                          ),
                          Spacer(),
                          Text(
                            '● $connectionText',
                            style: TextStyle(color: connectionColor),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 5.0),
                            child: Icon(Icons.info_outline,
                                color: chevronDownColor),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getConnectionIconBasedOnState() {
    switch (_connectionStatus) {
      case ConnectionStatus.initial:
        return Icons.cloud_download_outlined;
      case ConnectionStatus.loading:
        return Icons.downloading;
      case ConnectionStatus.connected:
        return Icons.cloud_done;
    }
  }

  Color _getConnectionColor() {
    switch (_connectionStatus) {
      case ConnectionStatus.initial:
        return chevronDownColor;
      case ConnectionStatus.loading:
        return chevronDownColor;
      case ConnectionStatus.connected:
        return connected;
    }
  }

  String _getConnectionText() {
    switch (_connectionStatus) {
      case ConnectionStatus.initial:
        return 'Not Connected';
      case ConnectionStatus.loading:
        return 'Not Connected';
      case ConnectionStatus.connected:
        return 'Connected';
    }
  }
}
