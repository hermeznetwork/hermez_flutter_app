import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/utils/hermez_colors.dart';

class BackupRow extends StatelessWidget {
  BackupRow(this.onPressed);

  final void Function() onPressed;

  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: HermezColors.blackTwo),
        padding: EdgeInsets.all(6.0),
        child: ListTile(
          onTap: () {
            if (onPressed != null) {
              onPressed();
            }
          },
          leading: Container(
              padding: EdgeInsets.only(top: 16.0),
              child: Image.asset("assets/backup_warning.png", height: 20)),
          trailing: Container(
              padding: EdgeInsets.only(top: 20.0),
              child: SvgPicture.asset("assets/arrow_right.svg",
                  height: 12, color: Colors.white)),
          title: Align(
            alignment: Alignment.centerLeft,
            //alignment: Alignment(-1.6, 0),
            child: Container(
              padding: EdgeInsets.only(top: 30.0, bottom: 30.0),
              child: Text(
                "Back up your wallet",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ));
  }
}
