import 'package:flutter/material.dart';
import 'package:hp_live_kit/presentation/theme/colors.dart';
import 'package:hp_live_kit/presentation/theme/text_size.dart';

class TabView extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  const TabView(
      {super.key,
      required this.text,
      required this.isSelected,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected ? selectedTabBlue : Colors.black;

    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Text(
        text,
        style: TextStyle(
            color: textColor,
            fontSize: TextSize.tabTextSize,
            height: 1.2,
            fontWeight: FontWeight.w400),
      ),
    );
  }
}
