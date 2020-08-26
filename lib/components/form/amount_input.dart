import 'package:flutter/material.dart';

class AmountInput extends StatelessWidget {
  AmountInput({
    this.labelText,
    this.hintText,
    this.errorText,
    this.onChanged,
    this.controller,
    this.maxLines,
    this.obscureText = false,
  });

  final ValueChanged<String> onChanged;
  final String errorText;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final int maxLines;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
      autocorrect: false,
      textAlign: TextAlign.center,
      maxLines: 1,
      cursorWidth: 0.0,
      style: TextStyle(
        color: Colors.black,
        fontSize: 48.0,
        fontWeight: FontWeight.w600,
      ),
      obscureText: this.obscureText,
      controller: this.controller,
      onChanged: this.onChanged,
      //maxLines: this.maxLines,
      decoration: InputDecoration.collapsed(
        hintStyle: TextStyle(
          color: Colors.black,
          fontSize: 48.0,
          fontWeight: FontWeight.w600,
        ),
        hintText: "0",
        //errorText: this.errorText,

      ),
    );
  }
}
