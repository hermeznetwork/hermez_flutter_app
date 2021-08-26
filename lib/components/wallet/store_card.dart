import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hermez/utils/hermez_colors.dart';

class StoreCard extends StatelessWidget {
  StoreCard(this.backgroundColor, this.imagePath,
      {this.height = 190,
      this.padding = 70,
      this.amount = 0,
      this.currency = "USD",
      this.vendorColor = HermezColors.lightGrey,
      this.enabled = true});

  final Color backgroundColor;
  final Color vendorColor;
  final String imagePath;
  final double height;
  final double padding;
  final num amount;
  final String currency;
  final bool enabled;

  Widget build(BuildContext context) {
    return Opacity(
        opacity: enabled ? 1 : 0.2,
        child: /*enabled
          ?*/
            content()
        /*: ColorFiltered(
              colorFilter: greyscale,
              child: content(),
            ),*/
        );
  }

  Widget content() {
    bool isSVG = (imagePath != null && imagePath.endsWith(".svg"));
    bool isPNG = (imagePath != null && imagePath.endsWith(".png"));
    bool isURL = Uri.parse(imagePath).isAbsolute;
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0), color: backgroundColor),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: Container(
              width: double.infinity,
              height: height,
              padding: EdgeInsets.all(padding),
              child: isURL
                  ? isSVG
                      ? SvgPicture.network(imagePath)
                      : Image.network(imagePath)
                  : isSVG
                      ? SvgPicture.asset(
                          imagePath,
                        )
                      : Image.asset(imagePath),
            ),
          ),
          amount != 0
              ? Container(
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: HermezColors.blueyGreyTwo.withOpacity(0.3),
                          blurRadius: 2.0,
                          spreadRadius: -2.0,
                          offset: Offset(
                              -4.0, 0.0), // shadow direction: bottom right
                        )
                      ],
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16.0),
                          bottomRight: Radius.circular(16.0)),
                      color: vendorColor),
                  width: 60,
                  height: double.infinity,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                        (this.currency == "USD" ? "\$" : "\€") +
                            this.amount.toString(),
                        style: TextStyle(
                            fontFamily: 'ModernEra',
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 25)),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  static ColorFilter greyscale = ColorFilter.matrix(<double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);
}
