import 'package:flutter/material.dart';
import 'package:hp_live_kit/presentation/theme/text_size.dart';

import '../../common/constant.dart';
import '../theme/dimen.dart';

class HPTextInputField extends StatelessWidget {
  final String label;
  final TextEditingController? textEditingController;

  const HPTextInputField({
    required this.label,
    this.textEditingController,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: Dimen.spacingM),
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: TextSize.body1,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: Dimen.spacingL,
              horizontal: Dimen.spacingL,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.black.withOpacity(.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: textEditingController,
              decoration: const InputDecoration.collapsed(
                hintText: Constant.emptyString,
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      );
}
