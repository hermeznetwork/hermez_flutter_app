import 'package:hermezwallet/components/wallet/home_balance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'components/dialog/alert.dart';
import 'components/menu/main_menu.dart';
import 'components/wallet/activity.dart';
import 'context/wallet/wallet_handler.dart';
import 'context/wallet/wallet_provider.dart';

class WalletHomePage extends HookWidget {
  WalletHomePage(this.title);

  final String title;

  WalletHandler store;

  ValueNotifier _currentIndex;


  @override
  Widget build(BuildContext context) {

    store = useWallet(context);
    _currentIndex = useState(0);

    useEffect(() {
      store.initialise();
      return null;
    }, []);

    final List<Widget> _children = [
      HomeBalance(
        address: store.state.address,
        ethBalance: store.state.ethBalance,
        tokenBalance: store.state.tokenBalance,
        defaultCurrency: store.state.defaultCurrency,
        cryptoList: store.state.cryptoList,
      ),
      Container(child: Text("Tab 2")),
      Activity(
        address: store.state.address,
        defaultCurrency: store.state.defaultCurrency,
        cryptoList: store.state.cryptoList,
      ),
    ];



    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex.value == 2 ? "Activity" : title),
        backgroundColor: _currentIndex.value == 2 ? Colors.white : Color.fromRGBO(249, 244, 235, 1.0),
        elevation: 0,
        actions: [
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
          IconButton(
            icon: ImageIcon(
              AssetImage('assets/account.png'),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed("/settings");
            },
          ),
        ],
      ),
      body: _children[_currentIndex.value],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            title: Text(''),
            icon: ImageIcon(
              AssetImage('assets/home.png'),
            ),
          ),
          BottomNavigationBarItem(
            title: Text(''),
            icon: ImageIcon(
              AssetImage('assets/transfer.png'),
            ),
          ),
          BottomNavigationBarItem(
            title: Text(''),
            icon: ImageIcon(
              AssetImage('assets/list.png'),
            ),
          ),
        ],
        currentIndex: _currentIndex.value,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.blueGrey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: onTabTapped,
      ),
    );

  }
  void onTabTapped(int index) {
    //setState(() {
      _currentIndex.value = index;
    //});
  }
}
