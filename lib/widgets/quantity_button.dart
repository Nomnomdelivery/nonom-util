import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nomnom_util/utils/color_pallete.dart';
import 'package:nomnom_util/utils/debouncer.dart';
import 'package:nomnom_util/widgets/qunatity_field.dart';

// ignore: must_be_immutable
class QuantityButton extends StatefulWidget {
  const QuantityButton({
    super.key,
    this.onDelete,
    required this.callback,
    required this.value,
    this.limit,
    this.withBox = false,
    this.fontSize = 26,
  });
  final int value;
  final int? limit;
  final double fontSize;
  final Function()? onDelete;
  final bool withBox;
  final ValueChanged<int> callback;
  @override
  State<QuantityButton> createState() => _QuantityButtonState();
}

class _QuantityButtonState extends State<QuantityButton> with ColorPalette {
  final Debouncer _debouncer = Debouncer(delay: Duration(milliseconds: 300));
  late int value = widget.value;

  void add() {
    if (widget.limit == null) {
      setState(() {
        value += 1;
      });
    } else {
      if (value < widget.limit!) {
        value += 1;
      }
    }
    setState(() {});
    _debouncer.updateValue(value);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _debouncer.onValueChanged = (value) {
        widget.callback(value);
        debugPrint(
          "Quantity updated to: $value",
        ); // Replace with API call or other logic
      };
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(100),
          ),

          child: InkWell(
            onTap: value == 1
                ? widget.onDelete
                : () {
                    setState(() {
                      if (value > 1) {
                        value -= 1;
                      }
                    });
                    _debouncer.updateValue(value);
                  },
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Icon(
                widget.onDelete != null && value == 1
                    ? Icons.delete_outline_outlined
                    : Icons.remove,
                size: widget.fontSize == 26 ? null : widget.fontSize + 2,
              ),
            ),
          ),
        ),

        InkWell(
          onTap: () async {
            await showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              barrierLabel: "",
              isScrollControlled: true,
              isDismissible: true,
              barrierColor: Colors.black38,
              builder: (context) => QuantityField(
                initialValue: value,
                callback: (int v) {
                  setState(() {
                    value = v;
                  });
                  widget.callback(v);
                },
                limit: widget.limit,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(100),
          ),
          child: InkWell(
            onTap: widget.limit == null
                ? add
                : value < widget.limit!
                ? add
                : () {
                    Fluttertoast.showToast(msg: "Quantity limit reached.");
                  },
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Icon(
                Icons.add,
                size: widget.fontSize == 26 ? null : widget.fontSize + 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
