import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveDialogButton extends StatelessWidget {
  const AdaptiveDialogButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.onLongPress,
  });
  final Function() onPressed;
  final Function()? onLongPress;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        child: child,
      );
    }
    return TextButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      child: child,
    );
  }
}
