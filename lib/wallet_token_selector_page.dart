import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/components/wallet/account_row.dart';
import 'package:hermez/service/network/api_client.dart';
import 'package:hermez/service/network/model/token.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/wallet_transfer_amount_page.dart';

class WalletTokenSelectorPage extends HookWidget {
  WalletTokenSelectorPage(this.amountType);

  final TransactionType amountType;

  List _elements = [
    {
      'symbol': 'USDT',
      'name': 'Tether',
      'value': 100.345646,
      'price': '€998.45'
    },
    {
      'symbol': 'ETH',
      'name': 'Ethereum',
      'value': 4.345646,
      'price': '€684.14'
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Token> supportedTokens;
    final apiClient = useMemoized(() => ApiClient('http://167.71.59.190:4010'));
    //useEffect(() {
    //final tokensRequest = TokensRequest();

    //return null;
    //},
    // when the apiClient change, useEffect will call the callback again.
    //[apiClient]);

    return Scaffold(
      appBar: new AppBar(
        title: new Text('Token',
            style: TextStyle(
                fontFamily: 'ModernEra',
                color: HermezColors.blackTwo,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0.0,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(null),
          ),
        ],
        leading: new Container(),
      ),
      body: FutureBuilder<List<Token>>(
        future: apiClient.getSupportedTokens(null),
        builder: (BuildContext context, AsyncSnapshot<List<Token>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: HermezColors.orange,
                ),
              ),
            );
          } else {
            if (snapshot.hasError) {
              // while data is loading:
              return Container(
                color: Colors.white,
                child: Center(
                  child:
                      Text('There was an error:' + snapshot.error.toString()),
                ),
              );
            } else {
              if (snapshot.hasData) {
                // data loaded:
                supportedTokens = snapshot.data;
                return Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      buildAccountsList(supportedTokens),
                    ],
                  ),
                );
              } else {
                return Container(
                  color: Colors.white,
                  child: Center(
                    child: Text('There is no data'),
                  ),
                );
              }
            }
          }
        },
      ),
    );
  }

  /*appBar: AppBar(
        //title: Text(_currentIndex.value == 2 ? "Activity" : title),
        //backgroundColor: _currentIndex.value == 2 ? Colors.white : Color.fromRGBO(249, 244, 235, 1.0),
        elevation: 0,
        //actions: [
          /*Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.refresh),
              onPressed: !store.state.loading
                  ? () async {
                      await store.fetchOwnBalance();
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Balance updated"),
                        duration: Duration(milliseconds: 800),
                      ));
                    }
                  : null,
            ),
          ),*/
          /*,
        ],*/
      ),*/

  //widget that builds the list
  Widget buildAccountsList(List<Token> supportedTokens) {
    return Expanded(
      child: Container(
          color: Colors.white,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: supportedTokens
                  .length, //set the item count so that index won't be out of range
              padding: const EdgeInsets.all(
                  16.0), //add some padding to make it look good
              itemBuilder: (context, i) {
                //item builder returns a row for each index i=0,1,2,3,4
                // if (i.isOdd) return Divider(); //if index = 1,3,5 ... return a divider to make it visually appealing

                // final index = i ~/ 2; //get the actual index excluding dividers.
                final index = i;
                print(index);
                final token = supportedTokens[index];
                return AccountRow(
                  token.name,
                  token.symbol,
                  token.USD.toString(),
                  token.decimals.toDouble(), // missing to get balance
                  false,
                  true,
                  (token, amount) async {
                    Navigator.pushReplacementNamed(context, "/transfer_amount",
                        arguments: AmountArguments(amountType, token));
                  },
                ); //build the row widget
              })),
    );
  }
}
