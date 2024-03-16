import 'package:mobile_dev_workshops/constants.dart';
import 'package:mobile_dev_workshops/features/wallet_actions/receive/receive_tab.dart';
import 'package:mobile_dev_workshops/features/wallet_actions/send/send_tab.dart';
import 'package:mobile_dev_workshops/services/wallets/wallet_service.dart';
import 'package:flutter/material.dart';

class WalletActionsBottomSheet extends StatelessWidget {
  const WalletActionsBottomSheet({
    required List<WalletService> walletServices,
    Key? key,
  })  : _walletServices = walletServices,
        super(key: key);

  final List<WalletService> _walletServices;

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
        body: Padding(
          padding: const EdgeInsets.all(kSpacingUnit * 4),
          child: TabBarView(
            children: [
              ReceiveTab(
                walletServices: _walletServices,
              ),
              SendTab(
                walletServices: _walletServices,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
