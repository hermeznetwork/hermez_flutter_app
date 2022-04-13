import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/utils/regex_input_formatter.dart';

class AmountInput extends StatefulWidget {
  AmountInput({
    Key key,
    this.labelText,
    this.hintText,
    this.errorText,
    this.onChanged,
    this.controller,
    this.maxLines,
    this.obscureText = false,
    this.decimals,
    this.enabled = true,
  }) : super(key: key);

  final String labelText;
  String hintText;
  final ValueChanged<String> onChanged;
  final String errorText;
  final bool obscureText;
  final int maxLines;
  final int decimals;
  final bool enabled;
  final TextEditingController controller;

  @override
  _AmountInputState createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  FocusNode focusNode = FocusNode();
  RegExInputFormatter _amountValidator;

  @override
  Widget build(BuildContext context) {
    widget.hintText = focusNode.hasFocus ? '' : '0';
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        widget.hintText = '';
      } else {
        widget.hintText = '0';
      }
      setState(() {});
    });
    _amountValidator = RegExInputFormatter.withRegex(
        '^\$|^(0|([1-9][0-9]{0,}))([\\.\\,][0-9]{0,${widget.decimals}})?\$');
    return TextField(
      keyboardType:
          TextInputType.numberWithOptions(signed: false, decimal: true),
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: TextInputAction.done,
      focusNode: focusNode,
      textAlign: TextAlign.center,
      maxLines: 1,
      enabled: widget.enabled,
      cursorWidth: 5.0,
      cursorColor: HermezColors.secondary,
      style: TextStyle(
        color: HermezColors.darkTwo,
        fontSize: 40,
        fontFamily: 'ModernEra',
        fontWeight: FontWeight.w700,
      ),
      obscureText: widget.obscureText,
      controller: widget.controller,
      onChanged: widget.onChanged,
      inputFormatters: [
        _amountValidator,
        TextInputFormatter.withFunction((oldValue, newValue) {
          var text = newValue.text;
          double value;
          if (oldValue.text == newValue.text) {
            return oldValue;
          }
          if (text.isNotEmpty) {
            text = text.replaceAll(",", ".");
            value = double.tryParse(text);
            if (value != null) {
              return TextEditingValue(
                text: text,
                selection: TextSelection.collapsed(
                  offset: newValue.selection.end,
                ),
              );
            } else {
              return oldValue;
            }
          } else {
            return TextEditingValue(
              text: newValue.text,
              selection: TextSelection.collapsed(
                offset: newValue.selection.end,
              ),
            );
            //return newValue;
          }
        })
      ],
      decoration: InputDecoration.collapsed(
        hintStyle: TextStyle(
          color: HermezColors.darkTwo,
          fontSize: 40,
          fontFamily: 'ModernEra',
          fontWeight: FontWeight.w700,
        ),
        hintText: widget.hintText,
      ),
    );
  }
}
