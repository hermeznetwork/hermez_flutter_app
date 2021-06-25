import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BlinkingTextAnimationArguments {
  final Color color;
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  BlinkingTextAnimationArguments(
      this.color, this.text, this.fontSize, this.fontWeight);
}

class BlinkingTextAnimation extends StatefulWidget {
  BlinkingTextAnimation({Key key, this.arguments}) : super(key: key);

  final BlinkingTextAnimationArguments arguments;

  @override
  _BlinkingAnimationState createState() => _BlinkingAnimationState();
}

class _BlinkingAnimationState extends State<BlinkingTextAnimation>
    with SingleTickerProviderStateMixin {
  Animation<Color> animation;
  AnimationController controller;

  initState() {
    super.initState();

    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    final CurvedAnimation curve =
        CurvedAnimation(parent: controller, curve: Curves.ease);

    animation = ColorTween(
            begin: widget.arguments.color.withAlpha(255),
            end: widget.arguments.color.withAlpha(100))
        .animate(curve);

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget child) {
          return new Container(
            child: Text(widget.arguments.text,
                style: TextStyle(
                  color: animation.value,
                  fontSize: widget.arguments.fontSize,
                  fontFamily: 'ModernEra',
                  fontWeight: widget.arguments.fontWeight,
                )),
          );
        });
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }
}
