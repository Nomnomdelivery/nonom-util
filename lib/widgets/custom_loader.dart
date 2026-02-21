import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CustomLoader extends StatelessWidget {
  const CustomLoader({
    super.key,
    this.label = 'Loading Data',
    this.color = Colors.white,
    this.alignment = MainAxisAlignment.center,
  });
  final String label;
  final MainAxisAlignment alignment;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        CircularProgressIndicator.adaptive(),
        if (label.isNotEmpty) ...{
          const Gap(15),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        },
      ],
    );
  }
}
