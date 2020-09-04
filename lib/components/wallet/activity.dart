import 'package:hermez/model/wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class Activity extends StatelessWidget {
  Activity({this.address, this.defaultCurrency, this.cryptoList});

  final String address;
  final WalletDefaultCurrency defaultCurrency;
  final List cryptoList;

  final bool _loading = false;

  List _elements = [
    {'to': '04526063', 'value': '-40', 'symbol': 'DAI', 'date': DateTime.now(), 'type' : 'send', 'status' : 'pending'},
    {'to': '05430444', 'value': '-80', 'symbol': 'DAI', 'date': DateTime.parse('2020-06-30'), 'type' : 'send', 'status' : 'invalid'},
    {'to': '', 'value': '200', 'symbol': 'USDT', 'date': DateTime.parse('2020-06-30'), 'type' : 'deposit', 'status' : 'done'},
    {'to': '0x4356...7634', 'value': '-400', 'symbol': 'USDT', 'date':  DateTime.parse('2019-12-20'), 'type' : 'withdraw', 'status' : 'done'},
    {'to': '07884543', 'value': '120', 'symbol': 'DAI', 'date': DateTime.parse('2019-12-20'), 'type' : 'receive', 'status' : 'done'},
    {'to': '05430444', 'value': '-0.005646', 'symbol': 'WETH', 'date': DateTime.parse('2019-12-20'), 'type' : 'send', 'status' : 'done'},
    ];

  /*@override
  void initState() {
    //override creation of state so that we can call our function
    super.initState();
    getCryptoPrices(); //this function is called which then sets the state of our app
  }*/

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      return buildGroupedList();
    }
  }

  Widget buildGroupedList() {
    return Container(
      color: Colors.white,
      child: GroupedListView<dynamic, DateTime>(
          groupBy: (element) => element['date'],
          elements: _elements,
          order: GroupedListOrder.DESC,
          useStickyGroupSeparators: true,
          groupSeparatorBuilder: (DateTime value) => Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0, bottom: 30.0, left: 20.0),
              child: Text(
                DateFormat('dd MMM yyyy').format(value),
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
          ),
      itemBuilder: (c, element) {
            var title = "";
            var subtitle = "";
            var type = element['type'];
            var status = element['status'];
            var icon = "";
            if (type == "deposit") {
              title = "Added";
              subtitle = "To your " + element['symbol'] + " account";
              icon = "assets/add.png";
            } else if (type == "send") {
              if (status == "done") {
                title = "Sent";
                icon = "assets/upload.png";
              } else if (status == "pending") {
                title = "Sending is in progress";
                icon = "assets/pending.png";
              } else if (status == "invalid") {
                title = "Sending failed";
                icon = "assets/warning.png";
              }
              subtitle = "To account " + element['to'];
            } else if (type == "withdraw") {
              if (status == "done") {
                title = "Withdrawn";
                icon = "assets/upload.png";
              } else if (status == "pending") {
                title = "Withdrawing is in progress";
                icon = "assets/pending.png";
              } else if (status == "invalid") {
                title = "Withdraw failed";
                icon = "assets/warning.png";
              }
              subtitle = "To your " + element['to'] + " address";
            } else if (type == "receive") {
              if (status == "done") {
                title = "Received";
                icon = "assets/deposit.png";
              } else if (status == "pending") {
                title = "Receiving is in progress";
                icon = "assets/pending.png";
              } else if (status == "invalid") {
                title = "Receiving failed";
                icon = "assets/warning.png";
              }
              subtitle = "From account " + element['to'];
            }
        return Container(
          child:
          ListTile(
            leading: _getLeadingWidget(icon,
                element['status'] == 'invalid' ? Color.fromRGBO(255, 239, 241, 1.0) : Colors.grey[100]),
            title: Container(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Text(title,
                maxLines: 1,
                style: TextStyle(fontFamily: 'ModernEra',
                    fontWeight: FontWeight.w800,
                    fontSize: 16)
                ,textAlign: TextAlign.left,
              ),
            ),
            subtitle: Container(
              child: Text(subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w600,
                    fontSize: 16)
                ,textAlign: TextAlign.left,
              ),
            ),
            trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    //color: double.parse(element['value']) < 0 ? Colors.transparent : Color.fromRGBO(228, 244, 235, 1.0),
                    padding: EdgeInsets.all(5.0),
                    child: Text("€36.45",
                      style: TextStyle(fontFamily: 'ModernEra',
                          fontWeight: FontWeight.w800,
                          color: double.parse(element['value']) < 0 ? Colors.black : Colors.green,
                          fontSize: 16)
                      ,textAlign: TextAlign.right,
                    ),
                  ),
                Container(
                    padding: EdgeInsets.all(5.0),
                    child: Text(element['value'] + " " + element['symbol'],
                    style: TextStyle(fontFamily: 'ModernEra',
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        fontSize: 16)
                    ,textAlign: TextAlign.right,
                  ),
                ),
                ]),
          ),
        );
      }),
    );
  }

  // takes in an object and color and returns a circle avatar with first letter and required color
  CircleAvatar _getLeadingWidget(String icon, Color color) {
    return new CircleAvatar(
      backgroundColor: color,
      child: Image.asset(icon)
    );
  }
}
