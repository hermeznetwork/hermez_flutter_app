import 'package:flutter/cupertino.dart';

class PaperForm extends StatelessWidget {
  PaperForm({this.children, this.padding = 8, this.actionButtons});

  final List<Widget> children;
  final List<Widget> actionButtons;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: EdgeInsets.all(this.padding),
        child: Column(children: [
          ...this.children,
          ..._buildButtons(),
        ]),
      ),
    );
  }

  List<Widget> _buildButtons() {
    if (this.actionButtons == null) return [Container()];

    return [
      const SizedBox(height: 10),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: this.actionButtons,
      )
    ];
  }
}
