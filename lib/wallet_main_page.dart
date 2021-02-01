import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hermez/components/wallet/balance.dart';

import 'components/dialog/alert.dart';
import 'components/menu/main_menu.dart';
import 'context/wallet/wallet_provider.dart';
import 'wallet_transfer_amount_page.dart';

class WalletMainPage extends HookWidget {
  WalletMainPage(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    var store = useWallet(context);

    useEffect(() {
      store.initialise();
      return null;
    }, []);

    return Scaffold(
      drawer: MainMenu(
        address: store.state.ethereumAddress,
        onReset: () async {
          Alert(
              title: "Warning",
              text:
                  "Without your seed phrase or private key you cannot restore your wallet balance",
              actions: [
                FlatButton(
                  child: Text("cancel"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                FlatButton(
                  child: Text("reset"),
                  onPressed: () async {
                    await store.resetWallet();
                    Navigator.popAndPushNamed(context, "/");
                  },
                )
              ]).show(context);
        },
      ),
      appBar: AppBar(
        title: Text(title),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.refresh),
              onPressed: !store.state.loading
                  ? () async {
                      if (store.state.txLevel == TransactionLevel.LEVEL1) {
                        await store.fetchOwnL1Balance();
                      } else {
                        await store.fetchOwnL2Balance();
                      }
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Balance updated"),
                        duration: Duration(milliseconds: 800),
                      ));
                    }
                  : null,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              Navigator.of(context).pushNamed("/amount");
            },
          ),
        ],
      ),
      body: Balance(
        address: store.state.ethereumAddress,
        ethBalance: store.state.ethBalance,
        tokensBalance: store.state.tokensBalance,
        cryptoList: store.state.cryptoList,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: '',
            icon: ImageIcon(
              AssetImage('assets/wallet.png'),
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: ImageIcon(
              AssetImage('assets/search.png'),
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: ImageIcon(
              AssetImage('assets/account.png'),
            ),
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.blueGrey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (int) {},
      ),
    );
  }
}
