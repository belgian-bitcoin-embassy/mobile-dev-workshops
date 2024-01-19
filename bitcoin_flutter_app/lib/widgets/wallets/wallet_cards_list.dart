import 'package:bitcoin_flutter_app/constants.dart';
import 'package:bitcoin_flutter_app/view_models/wallet_balance_view_model.dart';
import 'package:bitcoin_flutter_app/widgets/wallets/add_new_wallet_card.dart';
import 'package:bitcoin_flutter_app/widgets/wallets/wallet_balance_card.dart';
import 'package:flutter/material.dart';

class WalletCardsList extends StatelessWidget {
  const WalletCardsList(
    this.walletBalances, {
    required this.onAddNewWallet,
    required this.onDeleteWallet,
    super.key,
  });

  final List<WalletBalanceViewModel> walletBalances;
  final VoidCallback onAddNewWallet;
  final VoidCallback onDeleteWallet;

  @override
  Widget build(context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: walletBalances.isEmpty ? 1 : walletBalances.length,
      itemExtent: kSpacingUnit * 20,
      itemBuilder: (BuildContext context, int index) {
        if (walletBalances.isEmpty) {
          return AddNewWalletCard(onPressed: onAddNewWallet);
        } else {
          return WalletBalanceCard(
            walletBalances[index],
            onDelete: onDeleteWallet,
          );
        }
      },
    );
  }
}
