import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hermez/service/network/model/bitrefill_item.dart';
import 'package:hermez/utils/hermez_colors.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class BitrefillItemsArguments {
  final List<BitrefillItem> items;

  BitrefillItemsArguments(this.items);
}

class BitrefillItemsPage extends StatefulWidget {
  BitrefillItemsPage({Key key, this.arguments}) : super(key: key);

  final BitrefillItemsArguments arguments;

  @override
  _BitrefillItemsPageState createState() => _BitrefillItemsPageState();
}

class _BitrefillItemsPageState extends State<BitrefillItemsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Items",
            style: TextStyle(
                fontFamily: 'ModernEra',
                color: HermezColors.blackTwo,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          buildBitrefillItemList(),
        ],
      ),
    );
  }

  //widget that builds the list
  Widget buildBitrefillItemList() {
    return Expanded(
      child: Container(
          color: Colors.white,
          child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.arguments.items.length,
              padding: const EdgeInsets.all(16.0),
              separatorBuilder: (BuildContext context, int index) {
                return Container(
                  padding: const EdgeInsets.all(10.0),
                );
              },
              itemBuilder: (context, i) {
                final index = i;

                BitrefillItem item = widget.arguments.items.elementAt(index);

                return ListTile(
                  leading: _getLeadingWidget(item),
                  title: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(
                              left: 5.0, top: 24.0, bottom: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Text(
                                  item.baseName,
                                  style: TextStyle(
                                      fontFamily: 'ModernEra',
                                      color: HermezColors.blackTwo,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      item.giftInfo != null
                          ? Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(right: 10),
                              child: SvgPicture.asset(
                                'assets/gift.svg',
                                width: 20,
                                height: 20,
                              ),
                            )
                          : Container(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            child: Text(
                              (item.giftInfo != null
                                      ? ""
                                      : item.amount.toString() + " x ") +
                                  item.displayValue,
                              style: TextStyle(
                                  fontFamily: 'ModernEra',
                                  color: HermezColors.blackTwo,
                                  fontWeight: FontWeight.w700,
                                  height: 1.71,
                                  fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              })),
    );
  }

  // takes in an object and color and returns a circle avatar with first letter and required color
  CircleAvatar _getLeadingWidget(BitrefillItem item) {
    return new CircleAvatar(
      radius: 23,
      child: Image.network(
        "https://www.bitrefill.com/content/cn/b_rgb%3Affffff%2Cc_pad%2Ch_64%2Cw_64/v" +
            item.iconVersion +
            "/" +
            item.iconImage +
            ".jpg",
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Center(
            child: new CircularProgressIndicator(color: HermezColors.orange),
          );
        },
        /*errorBuilder: (context, error, stackTrace) =>
            Text('Some errors occurred!'),*/
      ),
    );
  }
}