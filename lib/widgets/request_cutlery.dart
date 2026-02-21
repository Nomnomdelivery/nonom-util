import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:nomnom_util/widgets/debounce_switch.dart';

class RequestCutlery extends StatefulWidget {
  const RequestCutlery({
    super.key,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
  });
  final ValueChanged<bool> onChanged;
  final EdgeInsets padding;
  @override
  State<RequestCutlery> createState() => _RequestCutleryState();
}

class _RequestCutleryState extends State<RequestCutlery> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "Include Cutlery",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const Gap(5),
              Tooltip(
                showDuration: 2000.ms,
                triggerMode: TooltipTriggerMode.tap,
                message: "Include utensils (e.g. spoon, fork, etc.)",
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade600, width: 2),
                  ),
                  padding: const EdgeInsets.all(1),
                  child: Icon(
                    Icons.question_mark,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          DebouncedSwitch(
            size: 30,
            valueCallback: widget.onChanged,
            initState: true,
          ),
        ],
      ),
    );
  }
}
