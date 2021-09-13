import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/utils/hermez_colors.dart';

import '../context/wallet/wallet_handler.dart';

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.

class CountrySelectorPage extends StatefulWidget {
  CountrySelectorPage({Key key, this.store}) : super(key: key);

  final WalletHandler store;

  @override
  _CountrySelectorPageState createState() => _CountrySelectorPageState();
}

class _CountrySelectorPageState extends State<CountrySelectorPage> {
  List<Country> _countries = [];
  List<Country> _searchList = [];
  bool _needRefresh = true;
  final TextEditingController _searchController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            //here
            FocusScope.of(context).unfocus();
            new TextEditingController().clear();
          },
          child: Container(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  snap: false,
                  elevation: 0.0,
                  centerTitle: true,
                  title: new Text("Select a country",
                      style: TextStyle(
                          fontFamily: 'ModernEra',
                          color: HermezColors.blackTwo,
                          fontWeight: FontWeight.w800,
                          fontSize: 20)),
                  bottom: AppBar(
                    automaticallyImplyLeading: false,
                    elevation: 0.0,
                    title: Container(
                      width: double.infinity,
                      height: 40,
                      color: Colors.white,
                      child: Center(
                        child: TextField(
                          controller: _searchController,
                          onChanged: searchOperation,
                          cursorColor: HermezColors.orange,
                          style: TextStyle(
                              fontFamily: 'ModernEra',
                              color: HermezColors.blackTwo,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Search a country',
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            hintStyle: TextStyle(
                                fontFamily: 'ModernEra',
                                color: HermezColors.blueyGreyTwo,
                                fontWeight: FontWeight.w500,
                                fontSize: 16),
                            prefixIcon: Icon(
                              Icons.search,
                              color: HermezColors.blueyGreyTwo,
                            ),
                            contentPadding: EdgeInsets.only(
                                left: 12, right: 12, top: 8, bottom: 8),
                            filled: true,
                            fillColor: Colors.white,
                            alignLabelWithHint: true,
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: HermezColors.orange),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: HermezColors.blueyGreyTwo),
                                borderRadius: BorderRadius.circular(20)),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: HermezColors.lightGrey),
                                borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Other Sliver Widgets
                SliverList(
                  delegate: SliverChildListDelegate([
                    FutureBuilder(
                        future: fetchData(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return buildCurrencyList();
                          } else {
                            return Center(
                              child: new CircularProgressIndicator(
                                  color: HermezColors.orange),
                            );
                          }
                        }),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Country>> fetchData() async {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/raw/countries.json");

    data = data.replaceAll("\n", "");
    dynamic json = jsonDecode(data);
    _countries = (json as List).map((item) => Country.fromJson(item)).toList();
    if (_needRefresh) {
      _searchList = List.from(_countries);
      _needRefresh = false;
    }
    return _countries;
  }

  void searchOperation(String searchText) {
    _searchList.clear();
    if (searchText == null || searchText.isEmpty) {
      _searchList = List.from(_countries);
    } else {
      //if (_isSearching != null) {
      _countries.forEach((product) {
        if (product.name.toLowerCase().contains(searchText.toLowerCase())) {
          _searchList.add(product);
        }
      });
    }
    setState(() {});
  }

  // takes in an object and color and returns a circle avatar with first letter and required color
  Widget _getLeadingWidget(Country item) {
    return CircleAvatar(
        radius: 25,
        child: ClipOval(
          child: SvgPicture.network(
            item.flag,
            fit: BoxFit.cover,
            allowDrawingOutsideViewBox: true,
            /*errorBuilder: (context, error, stackTrace) =>
            Text('Some errors occurred!'),*/
          ),
        ));
  }

  //widget that builds the list
  Widget buildCurrencyList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _searchList.length,
      padding:
          const EdgeInsets.all(16.0), //add some padding to make it look good
      separatorBuilder: (BuildContext context, int index) {
        return Container(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Divider(color: HermezColors.steel));
      },
      itemBuilder: (context, i) {
        //item builder returns a row for each index i=0,1,2,3,4
        // if (i.isOdd) return Divider(); //if index = 1,3,5 ... return a divider to make it visually appealing

        // final index = i ~/ 2; //get the actual index excluding dividers.
        final index = i;

        Country country = _searchList.elementAt(index);
        //final MaterialColor color = _colors[index %
        //    _colors.length]; //iterate through indexes and get the next colour
        return ListTile(
            leading: _getLeadingWidget(country),
            title: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.only(left: 5.0, top: 30.0, bottom: 30.0),
                child: Text(
                  country.name,
                  style: TextStyle(
                      fontFamily: 'ModernEra',
                      color: HermezColors.blackTwo,
                      fontWeight: FontWeight.w500,
                      fontSize: 16),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            trailing:
                /*widget.store.state.defaultCurrency == element
                        ? Radio(
                            groupValue: null,
                            activeColor: HermezColors.blackTwo,
                            value: null,
                            onChanged: (value) {
                              setState(() {
                                widget.store.updateDefaultCurrency(element);
                              });
                            },
                          )
                        :*/
                Radio(
              groupValue: null,
              value: country.name,
              activeColor: HermezColors.blackTwo,
              onChanged: (value) {
                setState(() {
                  //widget.store.updateDefaultCurrency(element);
                });
              },
            ),
            onTap: () {
              setState(() {
                //widget.store.updateDefaultCurrency(element);
              });
            }
            //store.fetchOwnBalance() = Wallet();
            //Navigator.of(context).pushNamed("/receiver", arguments: ReceiverArguments(ReceiverType.REQUEST));,
            );
        //return _buildRow(); //build the row widget
      },
    );
  }
}

class Country {
  final String name;
  final String flag;

  Country({this.name, this.flag});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'],
      flag: json['flag'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'flag': flag,
      };
}
