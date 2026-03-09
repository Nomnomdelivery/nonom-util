import 'package:flutter/material.dart';
import 'package:nomnom_util/utils/color_pallete.dart';

class ReplacedBadge extends StatelessWidget {
  const ReplacedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: ColorPalette.sgrey,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Replaced',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
