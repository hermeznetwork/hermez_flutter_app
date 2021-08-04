import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StoreCard extends StatelessWidget {
  StoreCard(this.backgroundColor);

  final Color backgroundColor;

  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0), color: backgroundColor),
      padding: EdgeInsets.all(70.0),
      child: Container(
        child: SvgPicture.asset(
          'assets/vendor_bitrefill.svg',
        ),
      ),
    );
  }
}
