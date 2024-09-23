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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 3.0,
        horizontal: 10.0,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.black.withOpacity(.3),
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: TextField(
        controller: textEditingController,
        decoration: const InputDecoration.collapsed(
          hintText: Constant.emptyString,
        ),
        keyboardType: TextInputType.url,
        autocorrect: false,
        style: const TextStyle(color: Colors.black, fontSize: 17.0),
      ),
    );
  }
}
