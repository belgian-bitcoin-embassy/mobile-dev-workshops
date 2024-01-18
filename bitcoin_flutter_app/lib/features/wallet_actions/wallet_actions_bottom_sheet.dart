import 'package:bitcoin_flutter_app/constants.dart';
import 'package:bitcoin_flutter_app/features/wallet_actions/receive/receive_tab.dart';
import 'package:bitcoin_flutter_app/features/wallet_actions/send/send_tab.dart';
import 'package:flutter/material.dart';

class WalletActionsBottomSheet extends StatelessWidget {
  const WalletActionsBottomSheet({Key? key}) : super(key: key);

  static const List<Tab> actionTabs = <Tab>[
    Tab(
      icon: Icon(Icons.arrow_downward),
      text: 'Receive funds',
    ),
    Tab(
      icon: Icon(Icons.arrow_upward),
      text: 'Send funds',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: actionTabs.length,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: const [
            CloseButton(),
          ],
          bottom: const TabBar(
            tabs: actionTabs,
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: const Padding(
          padding: EdgeInsets.all(kSpacingUnit * 4),
          child: TabBarView(
            children: [
              ReceiveTab(),
              SendTab(),
            ],
          ),
        ),
      ),
    );
  }
}
