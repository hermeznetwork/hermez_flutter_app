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
  final _addressValidator =
      RegExInputFormatter.withRegex('^hez:(0[xX])?[0-9a-fA-F]*\$');

  @override
  Widget build(BuildContext context) {
    return TextField(
      autocorrect: false,
      inputFormatters: <TextInputFormatter>[_addressValidator],
      textAlign: TextAlign.left,
      maxLines: 1,
      cursorWidth: 0.0,
      style: TextStyle(
        color: HermezColors.blackTwo,
        fontSize: 16.0,
        fontFamily: 'ModernEra',
        fontWeight: FontWeight.w500,
      ),
      obscureText: this.obscureText,
      controller: this.controller,
      onChanged: this.onChanged,
      //maxLines: this.maxLines,
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
