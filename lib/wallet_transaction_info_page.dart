import 'package:flutter/material.dart';

class TransactionInfoPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(243, 243, 243, 1),
    body:
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
        Align(
          alignment: Alignment.center,
            child:
              Image.asset(
              'assets/success.png',
            ),
        ),
          SizedBox(height: 32),
          Align(
            alignment: Alignment.center,
            child:
            Text('Transaction is completed.',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                )),
          ),
          SizedBox(height: 122),
          Align(
            alignment: Alignment.center,
            child:
            FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                  side: BorderSide(color: Color.fromRGBO(51, 51, 51, 1.0))),
              onPressed: () {
                Navigator.pop(context);
              },
              padding: EdgeInsets.all(15.0),
              color: Color.fromRGBO(51, 51, 51, 1.0),
              textColor: Colors.white,
              child: Text("Done",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          )
        ],
      ),
    );
  }
}
