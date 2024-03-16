import 'package:bitcoin_flutter_app/constants.dart';
import 'package:bitcoin_flutter_app/features/reserved_amount_actions/open_channel/open_channel_tab.dart';
import 'package:bitcoin_flutter_app/features/reserved_amount_actions/move_to_savings/move_to_savings_tab.dart';
import 'package:bitcoin_flutter_app/services/wallet_service.dart';
import 'package:flutter/material.dart';

class ReservedAmountActionsBottomSheet extends StatelessWidget {
  const ReservedAmountActionsBottomSheet({
    required LightningWalletService walletService,
    required BitcoinWalletService savingsWalletService,
    Key? key,
  })  : _walletService = walletService,
        _savingsWalletService = savingsWalletService,
        super(key: key);

  final LightningWalletService _walletService;
  final BitcoinWalletService _savingsWalletService;

  static const List<Tab> actionTabs = <Tab>[
    Tab(
      icon: Icon(Icons.flash_on),
      text: 'Instant Spending',
    ),
    Tab(
      icon: Icon(Icons.move_up),
      text: 'Savings',
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
              OpenChannelTab(walletService: _walletService),
              MoveToSavingsTab(
                walletService: _walletService,
                savingsWalletService: _savingsWalletService,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
