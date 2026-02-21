import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nomnom_util/utils/color_pallete.dart';

class QuantityField extends StatefulWidget {
  const QuantityField({
    super.key,
    required this.initialValue,
    required this.callback,
    this.label = 'Add Quantity',
    this.validator,
    required this.limit,
  });
  final int initialValue;
  final ValueChanged<int> callback;
  final int? limit;
  final String label;
  final FormFieldValidator? validator;
  @override
  State<QuantityField> createState() => _QuantityFieldState();
}

class _QuantityFieldState extends State<QuantityField> with ColorPalette {
  late final TextEditingController _qCtrl = TextEditingController(
    text: widget.initialValue.toString(),
  );
  final GlobalKey<FormState> _kForm = GlobalKey<FormState>();
  final FocusNode node = FocusNode();

  @override
  void dispose() {
    _qCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    node.requestFocus();
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Form(
              key: _kForm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: size.width * .15,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Color(0xFFE5E5E5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const Gap(15),
                        Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(20),
                  TextFormField(
                    focusNode: node,
                    controller: _qCtrl,
                    keyboardType: TextInputType.number,
                    canRequestFocus: true,
                    validator:
                        widget.validator ??
                        (text) {
                          final int? val = int.tryParse(text ?? "");
                          if (text == null || text.isEmpty) {
                            return "Field is required";
                          } else if (val == null) {
                            return 'Not a valid amount number';
                          } else if (widget.limit != null &&
                              (val > widget.limit!)) {
                            return "Limit Exceeded";
                          }
                          return null;
                        },
                    style: TextStyle(fontSize: 12),
                    cursorHeight: 13,
                  ),
                  const Gap(15),
                  Row(
                    children: [
                      Expanded(
                        child: MaterialButton(
                          height: 45,
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            Navigator.of(context).pop();
                          },
                          color: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: BorderSide(color: grey),
                          ),
                          child: Center(
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: MaterialButton(
                          height: 45,
                          onPressed: () {
                            if (_kForm.currentState!.validate()) {
                              FocusScope.of(context).unfocus();
                              Navigator.of(context).pop();
                              final value = int.parse(_qCtrl.text);
                              widget.callback(value);
                              if (mounted) setState(() {});
                            }
                            // FocusScope.of(context).unfocus();
                            // Navigator.of(context).pop();
                          },
                          color: orangePalette,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
