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
    this.layerOne = false,
    this.obscureText = false,
  });

  final ValueChanged<String> onChanged;
  final String errorText;
  final String labelText;
  final String hintText;
  final bool layerOne;
  final bool obscureText;
  final int maxLines;
  final TextEditingController controller;
  final _hezAddressValidator = RegExInputFormatter.withRegex(
      '^\$|^([hH]?[eE]?[zZ]?:?0?[xX]?)[a-fA-F0-9]{0,}\$');
  final _ethAddressValidator =
      RegExInputFormatter.withRegex('^\$|^(0?[xX]?)[a-fA-F0-9]{0,}\$');

  @override
  Widget build(BuildContext context) {
    return TextField(
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      /*inputFormatters: <TextInputFormatter>[
        layerOne ? _ethAddressValidator : _hezAddressValidator
      ],*/
      textAlign: TextAlign.left,
      maxLines: 1,
      cursorWidth: 2.0,
      cursorColor: HermezColors.primary,
      style: TextStyle(
        color: HermezColors.dark,
        fontSize: 16.0,
        fontFamily: 'ModernEra',
        fontWeight: FontWeight.w500,
      ),
      obscureText: this.obscureText,
      controller: this.controller,
      onChanged: this.onChanged,
      decoration: InputDecoration.collapsed(
        hintStyle: TextStyle(
          color: HermezColors.neutral,
          fontSize: 16,
          fontFamily: 'ModernEra',
          fontWeight: FontWeight.w500,
        ),
        hintText: layerOne ? "To 0xaddress" : "To hez:0xaddress",
        //errorText: this.errorText,
      ),
    );
  }
}
