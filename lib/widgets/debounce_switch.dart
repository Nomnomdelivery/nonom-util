import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nomnom_util/utils/color_pallete.dart';

class DebouncedSwitch extends StatefulWidget {
  const DebouncedSwitch({
    super.key,
    required this.valueCallback,
    required this.initState,
    this.size,
  });
  final ValueChanged<bool> valueCallback;
  final bool initState;
  final double? size;
  @override
  State<DebouncedSwitch> createState() => DebouncedSwitchState();
}

class DebouncedSwitchState extends State<DebouncedSwitch> with ColorPalette {
  Timer? _debounce;
  late bool state = widget.initState;
  // String _searchTerm = '';

  void _onSearchChanged(bool query) {
    // Cancel the previous timer if any
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Start a new timer
    _debounce = Timer(const Duration(milliseconds: 600), () {
      widget.valueCallback(state);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void toggleSwitch() {
    setState(() {
      state = !state;
    });
    _onSearchChanged(state);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.size != null) {
      return SizedBox(
        height: widget.size,
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: Switch.adaptive(
            value: state,
            inactiveTrackColor: grey,
            activeTrackColor: orangePalette,
            onChanged: (bool f) {
              setState(() {
                state = f;
              });
              _onSearchChanged(f);
            },
          ),
        ),
      );
    }
    return Switch.adaptive(
      value: state,
      inactiveTrackColor: grey,
      activeTrackColor: orangePalette,
      onChanged: (bool f) {
        setState(() {
          state = f;
        });
        _onSearchChanged(f);
      },
    );
  }
}
