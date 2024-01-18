import 'package:bitcoin_flutter_app/features/receive/receive_tab.dart';
import 'package:bitcoin_flutter_app/services/wallet_service.dart';
import 'package:flutter/material.dart';

class WalletActionsBottomSheet extends StatelessWidget {
  const WalletActionsBottomSheet({required this.bitcoinWalletService, Key? key})
      : super(key: key);

  final WalletService bitcoinWalletService;
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
        body: TabBarView(
          children: [
            ReceiveTab(bitcoinWalletService: bitcoinWalletService),
            Container(),
          ],
        ),
      ),
    );
  }
}
