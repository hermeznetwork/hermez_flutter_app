import 'package:flutter/material.dart';

class Alert {
  Alert({this.title = '', this.text = '', this.actions});

  final String title;
  final String text;
  final List<Widget> actions;

  show(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(text),
      actions: actions,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
