import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hp_live_kit/presentation/theme/colors.dart';
import 'package:hp_live_kit/presentation/theme/text_size.dart';
import '../../data/reporistory/livekit/room_constants.dart';
import '../theme/dimen.dart';

class ChatItem extends StatelessWidget {
  final String participant;
  final String text;

  static const double chatIconSize = 22.0;

  const ChatItem({super.key, required this.participant, required this.text});

  @override
  Widget build(BuildContext context) {
    final chatItemParams = _getChatItemParams();

    return Padding(
      padding: const EdgeInsets.only(
          top: Dimen.spacing10,
          left: Dimen.spacing10,
          right: Dimen.spacing10,
          bottom: Dimen.spacingXs),
      child: Container(
        decoration: BoxDecoration(
          color: chatItemParams.containerBackgroundColor.withOpacity(0.1),
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              top: Dimen.spacingXs,
              left: Dimen.spacingXs,
              right: Dimen.spacingXs,
              bottom: Dimen.spacingXs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    chatItemParams.icon,
                    height: chatIconSize,
                    width: chatIconSize,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: Dimen.spacingXs),
                    child: Text(
                      participant,
                      style: const TextStyle(
                          fontSize: TextSize.chatTextSize,
                          fontWeight: FontWeight.w400,
                          color: chatParticipantText),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: Dimen.spacingXs, top: Dimen.spacingXs),
                child: Text(
                  text,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                      fontSize: TextSize.chatTextSize,
                      fontWeight: FontWeight.w400,
                      color: chatMessageText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ChatItemViewParams _getChatItemParams() {
    if (participant == RoomConstants.botName) {
      return ChatItemViewParams(
          icon: 'assets/images/ic_robot.svg',
          containerBackgroundColor: chatAgentBackground);
    } else {
      return ChatItemViewParams(
          icon: 'assets/images/ic_person.svg',
          containerBackgroundColor: Colors.white);
    }
  }
}

class ChatItemViewParams {
  final String icon;
  final Color containerBackgroundColor;

  ChatItemViewParams(
      {required this.icon, required this.containerBackgroundColor});
}
