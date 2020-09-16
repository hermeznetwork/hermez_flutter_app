import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/utils/regex_input_formatter.dart';

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
  final _amountValidator = RegExInputFormatter.withRegex(
      '^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$');

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType:
          TextInputType.numberWithOptions(signed: false, decimal: true),
      autocorrect: false,
      textInputAction: TextInputAction.done,
      inputFormatters: <TextInputFormatter>[_amountValidator],
      textAlign: TextAlign.center,
      maxLines: 1,
      cursorWidth: 0.0,
      style: TextStyle(
        color: HermezColors.blackTwo,
        fontSize: 40,
        fontFamily: 'ModernEra',
        fontWeight: FontWeight.w700,
      ),
      obscureText: this.obscureText,
      controller: this.controller,
      onChanged: this.onChanged,
      decoration: InputDecoration.collapsed(
        hintStyle: TextStyle(
          color: HermezColors.blackTwo,
          fontSize: 40,
          fontFamily: 'ModernEra',
          fontWeight: FontWeight.w700,
        ),
        hintText: "0",
        //errorText: this.errorText,
      ),
    );
  }
}
