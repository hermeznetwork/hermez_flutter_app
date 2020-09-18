import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/utils/regex_input_formatter.dart';

class AddressInput extends StatelessWidget {
  AddressInput({
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
  final _addressValidator = RegExInputFormatter.withRegex(
      '^\$|^([hH]?[eE]?[zZ]?:?0?[xX]?)[a-fA-F0-9]{0,}\$');

  @override
  Widget build(BuildContext context) {
    return TextField(
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      inputFormatters: <TextInputFormatter>[_addressValidator],
      textAlign: TextAlign.left,
      maxLines: 1,
      cursorWidth: 2.0,
      cursorColor: HermezColors.orange,
      style: TextStyle(
        color: HermezColors.blackTwo,
        fontSize: 16.0,
        fontFamily: 'ModernEra',
        fontWeight: FontWeight.w500,
      ),
      obscureText: this.obscureText,
      controller: this.controller,
      onChanged: this.onChanged,
      decoration: InputDecoration.collapsed(
        hintStyle: TextStyle(
          color: HermezColors.blueyGreyTwo,
          fontSize: 16,
          fontFamily: 'ModernEra',
          fontWeight: FontWeight.w500,
        ),
        hintText: "To hez:0xaddress",
        //errorText: this.errorText,
      ),
    );
  }
}
