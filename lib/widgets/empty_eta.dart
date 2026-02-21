import 'package:flutter/widgets.dart';
import 'package:nomnom_util/utils/color_pallete.dart';

class EmptyEta extends StatelessWidget with ColorPalette {
  EmptyEta({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "-- min(s)",
      style: TextStyle(
        color: orangePalette,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
