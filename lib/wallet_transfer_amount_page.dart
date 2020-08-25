import 'package:hermez/components/wallet/transfer_form.dart';
import 'package:hermez/context/transfer/wallet_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'components/wallet/loading.dart';
import 'components/wallet/transfer_amount_form.dart';

class WalletTransferAmountPage extends HookWidget {

  @override
  Widget build(BuildContext context) {
    var transferStore = useWalletTransfer(context);
    var qrcodeAddress = useState();

    return Scaffold(
      appBar: AppBar(
        title: Text("Send"),
        elevation: 0.0,
      ),
      body: transferStore.state.loading
          ? Loading()
          : TransferAmountForm(
              token: qrcodeAddress.value,
              onSubmit: (address, amount) async {
                var success = await transferStore.transfer(address, amount);

                if (success) {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                }
              },
            ),
    );
  }
}
