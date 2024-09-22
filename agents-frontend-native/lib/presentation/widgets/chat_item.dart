import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hp_live_kit/presentation/theme/colors.dart';
import 'package:hp_live_kit/presentation/theme/text_size.dart';
import '../theme/dimen.dart';

class ChatItem extends StatelessWidget {
  final String participant;
  final String text;

  static const double chatIconSize = 22.0;

  const ChatItem({super.key, required this.participant, required this.text});

  @override
  Widget build(BuildContext context) {
    final icon = participant == 'COOL Agent'
        ? 'assets/images/ic_robot.svg'
        : 'assets/images/ic_person.svg';
    final containerBackground =
        participant == 'COOL Agent' ? chatAgentBackground : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(
          top: Dimen.spacing10,
          left: Dimen.spacing10,
          right: Dimen.spacing10,
          bottom: Dimen.spacingXs),
      child: Container(
        decoration: BoxDecoration(
          color: containerBackground.withOpacity(0.1),
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
                    icon,
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
}
