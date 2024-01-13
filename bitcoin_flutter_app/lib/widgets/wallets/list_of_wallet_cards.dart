import 'package:bitcoin_flutter_app/constants.dart';
import 'package:bitcoin_flutter_app/widgets/wallets/add_new_wallet_card.dart';
import 'package:bitcoin_flutter_app/widgets/wallets/wallet_balance_card.dart';
import 'package:flutter/material.dart';

class ListOfWalletCards extends StatelessWidget {
  const ListOfWalletCards({
    super.key,
  });

  final count = 2;

  @override
  Widget build(context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: count,
      itemExtent: kSpacingUnit * 20,
      itemBuilder: (BuildContext context, int index) {
        if (index == count - 1) {
          return const AddNewWalletCard();
        } else {
          return const WalletBalanceCard();
        }
      },
    );
  }
}
