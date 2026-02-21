import 'dart:async';
import 'package:flutter/material.dart';

class DebouncedTextField extends StatefulWidget {
  final Function(String text) onDebouncedChange;
  final Duration debounceDuration;
  final TextInputType? keyboardType;
  final Color? textColor;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final String? initText;

  @override
  State<DebouncedTextField> createState() => _DebouncedTextFieldState();
  const DebouncedTextField({
    super.key,
    this.textColor,
    required this.onDebouncedChange,
    this.hintText,
    this.labelText,
    this.initText,
    this.prefixIcon,
    this.debounceDuration = const Duration(milliseconds: 700),
    this.keyboardType,
  });
}

class _DebouncedTextFieldState extends State<DebouncedTextField> {
  Timer? _debounceTimer;
  late final TextEditingController _controller = TextEditingController()
    ..text = widget.initText ?? "";

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    // Cancel the previous debounce timer if still active
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

    // Start a new debounce timer
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onDebouncedChange(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: widget.keyboardType,
      controller: _controller,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: widget.textColor,
      ),
      cursorColor: widget.textColor,
      onChanged: _onTextChanged,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        labelText: widget.labelText,
        hintText: widget.hintText ?? widget.labelText,
        prefixIcon: widget.prefixIcon,
        hintStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: widget.textColor,
        ),
      ),
    );
  }
}
