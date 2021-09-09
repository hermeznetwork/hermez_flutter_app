import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hermez/components/form/amount_input.dart';
import 'package:hermez/components/wallet/store_card.dart';
import 'package:hermez/context/wallet/wallet_handler.dart';
import 'package:hermez/service/network/model/bitrefill_item.dart';
import 'package:hermez/service/network/model/pay_product.dart';
import 'package:hermez/service/network/model/pay_provider.dart';
import 'package:hermez/utils/hermez_colors.dart';
import 'package:hermez/utils/pop_result.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../constants.dart';
import 'bitrefill_form.dart';

class StoreItemSelectorArguments {
  WalletHandler store;
  BuildContext parentContext;
  PayProvider provider;
  Color vendorColor;

  StoreItemSelectorArguments(
      this.store, this.parentContext, this.provider, this.vendorColor);
}

class StoreItemSelectorPage extends StatefulWidget {
  StoreItemSelectorPage({Key key, this.arguments}) : super(key: key);

  final StoreItemSelectorArguments arguments;

  @override
  _StoreItemSelectorPageState createState() => _StoreItemSelectorPageState();
}

class _StoreItemSelectorPageState extends State<StoreItemSelectorPage> {
  GlobalKey<FormState> _storeItemSelectorScreenkey =
      GlobalKey<FormState>(debugLabel: '_storeItemSelectorScreenkey');
  GlobalKey<ScaffoldMessengerState> _listKey = GlobalKey();
  List<PayProduct> _products;
  List<BitrefillItem> _items = [];
  final TextEditingController amountController = TextEditingController();
  final TextEditingController _searchController = new TextEditingController();
  int _selectedFixedValueIndex = -1;
  int _selectedItemAmount = -1;

  List<PayProduct> _searchList = [];
  bool _needRefresh = true;

  @override
  Widget build(BuildContext context) {
    final String currency =
        widget.arguments.store.state.defaultCurrency.toString().split('.').last;

    return Scaffold(
      key: _storeItemSelectorScreenkey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            //here
            FocusScope.of(context).unfocus();
            new TextEditingController().clear();
          },
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      floating: true,
                      pinned: true,
                      snap: false,
                      elevation: 0.0,
                      centerTitle: true,
                      title: new Text("Select item",
                          style: TextStyle(
                              fontFamily: 'ModernEra',
                              color: HermezColors.blackTwo,
                              fontWeight: FontWeight.w800,
                              fontSize: 20)),
                      actions: [
                        Stack(children: [
                          new IconButton(
                              icon: new Icon(Icons.shopping_cart_outlined),
                              onPressed: () {
                                showBarModalBottomSheet(
                                  context: context,
                                  builder: (context) => buildCartList(),
                                );
                              }),
                          _items != null && _items.length > 0
                              ? Positioned(
                                  bottom: 35,
                                  right: 25,
                                  child: Stack(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 6.0,
                                            right: 6.0,
                                            top: 3.7,
                                            bottom: 3.0),
                                        decoration: BoxDecoration(
                                          color: HermezColors.darkOrange,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(_items.length.toString(),
                                            style: TextStyle(
                                                fontFamily: 'ModernEra',
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 12)),
                                      )
                                    ],
                                  ),
                                )
                              : Container()
                        ]),
                      ],
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
                                labelText: 'Search a product',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                hintStyle: TextStyle(
                                    fontFamily: 'ModernEra',
                                    color: HermezColors.blueyGreyTwo,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: HermezColors.blueyGreyTwo,
                                ),
                                suffixIcon: new Container(
                                  padding: EdgeInsets.symmetric(vertical: 2),
                                  child: IconButton(
                                    splashRadius: 1,
                                    onPressed: () {
                                      //here
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        _searchController.clear();
                                        FocusScope.of(context).unfocus();
                                      });
                                      showBarModalBottomSheet(
                                        context: context,
                                        builder: (context) => buildFilterList(),
                                      );
                                    },
                                    icon: ImageIcon(
                                        AssetImage('assets/filter.png'),
                                        color: HermezColors.blueyGreyTwo),
                                  ),
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
                                    borderSide: BorderSide(
                                        color: HermezColors.lightGrey),
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
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                          key: _listKey,
                                          children: ListTile.divideTiles(
                                              context: context,
                                              color: HermezColors.transparent,
                                              tiles: List.generate(
                                                  _searchList.length ==
                                                          (_searchList.length ~/
                                                                  2) *
                                                              2
                                                      ? (_searchList.length ~/
                                                          2)
                                                      : (_searchList.length ~/
                                                              2) +
                                                          1,
                                                  (index) => Row(
                                                      children: List.generate(
                                                          2,
                                                          (rowIndex) =>
                                                              Expanded(
                                                                child: ((index *
                                                                                2) +
                                                                            (rowIndex +
                                                                                1)) <=
                                                                        _searchList
                                                                            .length
                                                                    ? new GestureDetector(
                                                                        onTap: _searchList[(index * 2) + rowIndex].enabled
                                                                            ? () {
                                                                                //List<BitrefillItem> _items = [];
                                                                                /*BitrefillItem item = BitrefillItem(
                                              id: _products[0].id.toString(),
                                              slug: _products[0].name,
                                              name: "Amazon.es Spain",
                                              baseName: "Amazon.es",
                                              iconImage: "amazon-icon",
                                              iconVersion: "1557911836",
                                              //recipient: "raul@iden3.com",
                                              amount: 1,
                                              value: 5,
                                              displayValue: "€5.00",
                                              currency: "EUR",
                                              giftInfo: null);
                                          setState(() {
                                            _items.add(item);
                                          });*/
                                                                                _selectedItemAmount = 1;
                                                                                amountController.text = _selectedItemAmount.toString();
                                                                                _selectedFixedValueIndex = -1;
                                                                                showBarModalBottomSheet(
                                                                                  context: context,
                                                                                  builder: (context) => buildItemDetails(),
                                                                                );

                                                                                /*Navigator.pushNamed(
                                          context, '/bitrefill_form',
                                          arguments: BitrefillFormArguments(
                                              widget.arguments.provider,
                                              _items,
                                              widget.arguments.store))
                                      .then((results) {
                                    if (results is PopWithResults) {
                                      PopWithResults popResult = results;
                                      if (popResult.toPage ==
                                          "/store_item_selector") {
                                        // TODO do stuff
                                      } else {
                                        Navigator.of(context).pop(results);
                                      }
                                    }
                                  });*/
                                                                                /*Navigator.pushNamed(
                            widget.arguments.parentContext, "/web_explorer",
                            arguments:
                                WebExplorerArguments(widget.arguments.store));*/
                                                                              }
                                                                            : () {
                                                                                showFlush('Service will be available soon', context);
                                                                              },
                                                                        child:
                                                                            Container(
                                                                          margin:
                                                                              EdgeInsets.all(6),
                                                                          child:
                                                                              StoreCard(
                                                                            HermezColors.lightGrey,
                                                                            _searchList[(index * 2) + rowIndex].imageUrl,
                                                                            height:
                                                                                120,
                                                                            padding:
                                                                                20,
                                                                            enabled:
                                                                                _searchList[(index * 2) + rowIndex].enabled,
                                                                            //amount: 5,
                                                                            currency:
                                                                                currency,
                                                                            vendorColor:
                                                                                widget.arguments.vendorColor,
                                                                            onInfoPressed: _searchList[(index * 2) + rowIndex].enabled
                                                                                ? () {
                                                                                    showBarModalBottomSheet(
                                                                                      context: context,
                                                                                      builder: (context) => buildItemInfo(),
                                                                                    );
                                                                                  }
                                                                                : null,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Container(),
                                                              ))))).toList()),
                                    ),
                                  ],
                                );
                              } else {
                                return Expanded(
                                    child: Center(
                                  child: new CircularProgressIndicator(
                                      color: HermezColors.orange),
                                ));
                              }
                            }),
                      ]),
                    ),
                  ],
                ),
              ),
              _buildButton(
                  "Continue",
                  _items != null && _items.length > 0
                      ? () {
                          Navigator.pushNamed(context, '/bitrefill_form',
                                  arguments: BitrefillFormArguments(
                                      widget.arguments.provider,
                                      _items,
                                      widget.arguments.store))
                              .then((results) {
                            if (results is PopWithResults) {
                              PopWithResults popResult = results;
                              if (popResult.toPage == "/store_item_selector") {
                                // TODO do stuff
                              } else {
                                Navigator.of(context).pop(results);
                              }
                            }
                          });
                        }
                      : null),
            ],
          ),
        ),
      ),
    );
  }

  void showFlush(String messageText, BuildContext context) {
    Flushbar(
      messageText: Text(
        messageText,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: HermezColors.blackTwo,
          fontSize: 16,
          fontFamily: 'ModernEra',
          fontWeight: FontWeight.w700,
        ),
      ),
      boxShadows: [
        BoxShadow(
          color: HermezColors.blueyGreyTwo.withAlpha(64),
          offset: Offset(0, 4),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ],
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      borderColor: HermezColors.blueyGreyTwo.withAlpha(64),
      borderRadius: BorderRadius.all(Radius.circular(12)),
      backgroundColor: Colors.white,
      margin: EdgeInsets.all(16.0),
      isDismissible: true,
      duration: Duration(seconds: FLUSHBAR_AUTO_HIDE_DURATION),
    ).show(_listKey.currentContext);
  }

  Future<bool> fetchData() async {
    /*_products =*/ await widget.arguments.store
        .getPayProducts(widget.arguments.provider.id);
    _products = [];
    _products.add(PayProduct(
        id: 1,
        name: "Amazon",
        providerId: 1,
        imageUrl:
            "https://cdn.freebiesupply.com/images/large/2x/amazon-logo-transparent.png"));
    _products.add(PayProduct(
        id: 2,
        name: "Netflix",
        providerId: 1,
        imageUrl: "https://www.freepnglogos.com/uploads/netflix-logo-0.png",
        enabled: false));
    _products.add(PayProduct(
        id: 3,
        name: "Ikea",
        providerId: 1,
        imageUrl:
            "https://upload.wikimedia.org/wikipedia/commons/c/c5/Ikea_logo.svg",
        enabled: false));
    _products.add(PayProduct(
        id: 4,
        name: "Spotify",
        providerId: 1,
        imageUrl:
            "https://upload.wikimedia.org/wikipedia/commons/2/26/Spotify_logo_with_text.svg",
        enabled: false));
    _products.add(PayProduct(
        id: 5,
        name: "Airbnb",
        providerId: 1,
        imageUrl:
            "https://cdn.freelogovectors.net/wp-content/uploads/2016/12/airbnb-logo.png",
        enabled: false));

    if (_needRefresh) {
      _searchList = List.from(_products);
      _needRefresh = false;
    }
    return true;
  }

  Widget buildItemInfo() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return SafeArea(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          StoreCard(
                            HermezColors.lightGrey,
                            "https://cdn.freebiesupply.com/images/large/2x/amazon-logo-transparent.png",
                            height: 220,
                            padding: 50,
                            //amount: 5,
                            currency: "EUR",
                            vendorColor: widget.arguments.vendorColor,
                          ),
                          SizedBox(height: 20),
                          RatingBar.builder(
                            initialRating: 5,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            ignoreGestures: true,
                            itemCount: 5,
                            itemSize: 30,
                            itemPadding: EdgeInsets.symmetric(horizontal: 5.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              print(rating);
                            },
                          ),
                          Text(
                            "Rating: 5 - 30 reviews",
                            style: TextStyle(
                              color: HermezColors.blueyGreyTwo,
                              fontSize: 16,
                              height: 1.6,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Compra tarjetas de regalo de Amazon con Hermez y elige entre los millones de artículos de Amazon.es, entregados directamente en tu puerta. ¡Convierte tus tokens en tarjetas regalo para vivir con cripto!",
                            style: TextStyle(
                              color: HermezColors.blueyGreyTwo,
                              fontSize: 16,
                              height: 1.6,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Este código de regalo funciona en los siguientes países: 🇪🇸 España and 🇫🇷 Francia."
                            "\n\nNo uses tarjetas de regalo en cuentas nuevas de Amazon sin tarjetas de crédito o débito agregadas, o tu cuenta puede bloquearse hasta que puedan verificar su identidad.",
                            style: TextStyle(
                              color: HermezColors.blueyGreyTwo,
                              fontSize: 16,
                              height: 1.6,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Después de recibir el código de su tarjeta de regalo de Amazon, deberá iniciar sesión en su cuenta de Amazon.\n' +
                                'Haga clic en "Aplicar una tarjeta de regalo a su cuenta".\n' +
                                'A continuación, deberá ingresar el código de su tarjeta de regalo de Amazon y hacer clic en "Aplicar a su saldo".',
                            style: TextStyle(
                              color: HermezColors.blueyGreyTwo,
                              fontSize: 16,
                              height: 1.6,
                              fontFamily: 'ModernEra',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildItemDetails() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
      return SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /*Expanded(
                child: SingleChildScrollView(
                  child: */
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    buildAmountSelector(),
                    SizedBox(height: 20),
                    buildValueSelector(setModalState),
                  ],
                ),
              ),
              /*,),
                ),
              ),*/
              _buildButton(
                  "Add to Cart",
                  _selectedItemAmount > 0 && _selectedFixedValueIndex >= 0
                      ? () {
                          int value = 0;
                          switch (_selectedFixedValueIndex) {
                            case 0:
                              value = 5;
                              break;
                            case 1:
                              value = 20;
                              break;
                            case 2:
                              value = 50;
                              break;
                            case 3:
                              value = 100;
                              break;
                          }
                          BitrefillItem item = BitrefillItem(
                              id: _products[0].id.toString(),
                              slug: _products[0].name,
                              name: "Amazon.es Spain",
                              baseName: "Amazon.es",
                              iconImage: "amazon-icon",
                              iconVersion: "1557911836",
                              //recipient: "raul@iden3.com",
                              amount: _selectedItemAmount,
                              value: value,
                              displayValue: '€$value.00',
                              currency: "EUR",
                              giftInfo: null);
                          setState(() {
                            _items.add(item);
                          });
                          Navigator.pop(context);
                          showFlush('Item added to the cart', context);
                        }
                      : null),
            ],
          ),
        ),
      );
    });
  }

  Widget buildAmountSelector() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: HermezColors.blueyGreyThree,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.only(top: 20.0, bottom: 30, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Text(
              "Amount",
              style: TextStyle(
                color: HermezColors.black,
                fontSize: 16,
                fontFamily: 'ModernEra',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40.0),
                    color: HermezColors.lightGrey,
                  ),
                  child: IconButton(
                    onPressed: () {
                      if (int.parse(amountController.text) > 1) {
                        amountController.text =
                            (int.parse(amountController.text) - 1).toString();
                      }
                      _selectedItemAmount = int.parse(amountController.text);
                      setState(() {});
                    },
                    padding: EdgeInsets.only(left: 10),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: HermezColors.blueyGreyTwo,
                    ),
                    /*child: SvgPicture.asset(
                        "assets/bt_send.svg",
                        fit: BoxFit.cover,
                      ),*/
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: AmountInput(
                  onChanged: (value) {},
                  enabled: false,
                  controller: amountController,
                  decimals: 0,
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  //alignment: Alignment.center,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40.0),
                      color: HermezColors.lightGrey,
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (int.parse(amountController.text) >= 0) {
                          amountController.text =
                              (int.parse(amountController.text) + 1).toString();
                        }
                        _selectedItemAmount = int.parse(amountController.text);
                        setState(() {});
                      },
                      padding: EdgeInsets.only(left: 3),
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: HermezColors.blueyGreyTwo,
                      ),
                      /*child: SvgPicture.asset(
                        "assets/bt_send.svg",
                        fit: BoxFit.cover,
                      ),*/
                    ),
                  ),
                ),
                /*IconButton(
                      iconSize: 56,
                      padding: EdgeInsets.all(0),
                      icon: Image.asset("assets/flash_on.png",
                          width: 56, height: 56),
                      onPressed: () async {
                        if (int.parse(amountController.text) >= 0) {
                          amountController.text =
                              (int.parse(amountController.text) + 1).toString();
                        }
                        setState(() {});
                      }),*/
              ), //title to be name of the crypto
            ],
          ),
        ],
      ),
    );
  }

  Widget buildValueSelector(StateSetter setModalState) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: HermezColors.blueyGreyThree,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Text(
              "Value",
              style: TextStyle(
                color: HermezColors.black,
                fontSize: 16,
                fontFamily: 'ModernEra',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    padding: EdgeInsets.only(
                        top: 20, bottom: 20, left: 10, right: 10),
                    backgroundColor: _selectedFixedValueIndex == 0
                        ? HermezColors.blueyGreyTwo
                        : HermezColors.lightGrey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setModalState(() {
                      _selectedFixedValueIndex = 0;
                    });
                  },
                  child: Text(
                    '5€',
                    style: TextStyle(
                      color: _selectedFixedValueIndex == 0
                          ? HermezColors.lightGrey
                          : HermezColors.blueyGreyTwo,
                      fontSize: 16,
                      fontFamily: 'ModernEra',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Flexible(
                flex: 1,
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    padding: EdgeInsets.only(
                        top: 20, bottom: 20, left: 10, right: 10),
                    backgroundColor: _selectedFixedValueIndex == 1
                        ? HermezColors.blueyGreyTwo
                        : HermezColors.lightGrey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setModalState(() {
                      _selectedFixedValueIndex = 1;
                    });
                  },
                  child: Text(
                    '20€',
                    style: TextStyle(
                      color: _selectedFixedValueIndex == 1
                          ? HermezColors.lightGrey
                          : HermezColors.blueyGreyTwo,
                      fontSize: 16,
                      fontFamily: 'ModernEra',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Flexible(
                flex: 1,
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    padding: EdgeInsets.only(
                        top: 20, bottom: 20, left: 10, right: 10),
                    backgroundColor: _selectedFixedValueIndex == 2
                        ? HermezColors.blueyGreyTwo
                        : HermezColors.lightGrey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setModalState(() {
                      _selectedFixedValueIndex = 2;
                    });
                  },
                  child: Text(
                    '50€',
                    style: TextStyle(
                      color: _selectedFixedValueIndex == 2
                          ? HermezColors.lightGrey
                          : HermezColors.blueyGreyTwo,
                      fontSize: 16,
                      fontFamily: 'ModernEra',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Flexible(
                flex: 1,
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    padding: EdgeInsets.only(
                        top: 20, bottom: 20, left: 10, right: 10),
                    backgroundColor: _selectedFixedValueIndex == 3
                        ? HermezColors.blueyGreyTwo
                        : HermezColors.lightGrey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setModalState(() {
                      _selectedFixedValueIndex = 3;
                    });
                  },
                  child: Text(
                    '100€',
                    style: TextStyle(
                      color: _selectedFixedValueIndex == 3
                          ? HermezColors.lightGrey
                          : HermezColors.blueyGreyTwo,
                      fontSize: 16,
                      fontFamily: 'ModernEra',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          /*Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40.0),
                      color: HermezColors.blueyGreyThree),
                  child: IconButton(
                    onPressed: () {
                      if (int.parse(amountController.text) > 1) {
                        amountController.text =
                            (int.parse(amountController.text) - 1).toString();
                      }
                      setState(() {});
                    },
                    padding: EdgeInsets.only(left: 10),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    /*child: SvgPicture.asset(
                        "assets/bt_send.svg",
                        fit: BoxFit.cover,
                      ),*/
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: AmountInput(
                  onChanged: (value) {},
                  enabled: false,
                  controller: amountController,
                  decimals: 0,
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  //alignment: Alignment.center,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40.0),
                        color: HermezColors.blueyGreyThree),
                    child: IconButton(
                      onPressed: () {
                        if (int.parse(amountController.text) >= 0) {
                          amountController.text =
                              (int.parse(amountController.text) + 1).toString();
                        }
                        setState(() {});
                      },
                      padding: EdgeInsets.only(left: 3),
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      ),
                      /*child: SvgPicture.asset(
                        "assets/bt_send.svg",
                        fit: BoxFit.cover,
                      ),*/
                    ),
                  ),
                ),
                /*IconButton(
                      iconSize: 56,
                      padding: EdgeInsets.all(0),
                      icon: Image.asset("assets/flash_on.png",
                          width: 56, height: 56),
                      onPressed: () async {
                        if (int.parse(amountController.text) >= 0) {
                          amountController.text =
                              (int.parse(amountController.text) + 1).toString();
                        }
                        setState(() {});
                      }),*/
              ), //title to be name of the crypto
            ],
          ),*/
        ],
      ),
    );
  }

  Widget buildCartList() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
      return Container(
        color: Colors.white,
        child: ListView.separated(
            shrinkWrap: true,
            itemCount: _items.length,
            padding: const EdgeInsets.all(16.0),
            separatorBuilder: (BuildContext context, int index) {
              return Container(
                padding: const EdgeInsets.all(10.0),
              );
            },
            itemBuilder: (context, i) {
              final index = i;

              BitrefillItem item = _items.elementAt(index);

              return ListTile(
                leading: _getLeadingWidget(item),
                title: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding:
                            EdgeInsets.only(left: 5.0, top: 24.0, bottom: 24.0),
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
                    IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _items.removeAt(index);
                          });
                          setModalState(() {});
                          if (_items.length == 0) {
                            Navigator.pop(context);
                          }
                        },
                        icon: Icon(Icons.delete)),
                  ],
                ),
              );
            }),
      );
    });
  }

  Widget buildFilterList() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
      return Container(
        color: Colors.white,
      );
    });
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

  Widget _buildButton(String title, Function() onPressed) {
    return Column(children: <Widget>[
      Container(
        margin: const EdgeInsets.all(16),
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: SizedBox(
            width: double.infinity,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.0),
              ),
              onPressed: onPressed,
              padding: EdgeInsets.only(
                  top: 18.0, bottom: 18.0, right: 24.0, left: 24.0),
              disabledColor: HermezColors.blueyGreyTwo,
              color: HermezColors.darkOrange,
              textColor: Colors.white,
              disabledTextColor: Colors.grey,
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'ModernEra',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  void searchOperation(String searchText) {
    _searchList.clear();
    if (searchText == null || searchText.isEmpty) {
      _searchList = List.from(_products);
    } else {
      //if (_isSearching != null) {
      _products.forEach((product) {
        if (product.name.toLowerCase().contains(searchText.toLowerCase())) {
          _searchList.add(product);
        }
      });
    }
    setState(() {});
  }
}
