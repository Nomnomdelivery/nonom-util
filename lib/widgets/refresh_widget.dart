import 'package:flutter/material.dart';
import 'package:nomnom_util/utils/color_pallete.dart';

class RefreshWidget extends StatefulWidget {
  const RefreshWidget({
    super.key,
    required this.child,
    required this.onRefresh,
  });
  final Widget child;
  final Function() onRefresh;
  @override
  State<RefreshWidget> createState() => _RefreshWidgetState();
}

class _RefreshWidgetState extends State<RefreshWidget> with ColorPalette {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Future<void> _refreshItems() async {
    // Simulate a network request or data fetch
    await Future.delayed(Duration(milliseconds: 500));
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      color: orangePalette,
      key: _refreshIndicatorKey,
      onRefresh: _refreshItems,
      child: widget.child,
    );
  }
}
