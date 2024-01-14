import 'package:bitcoin_flutter_app/constants.dart';
import 'package:bitcoin_flutter_app/widgets/transactions/transactions_list.dart';
import 'package:bitcoin_flutter_app/widgets/wallets/wallet_cards_list.dart';
import 'package:bitcoin_flutter_app/widgets/wallets/wallet_actions_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      endDrawer: const Drawer(),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: kSpacingUnit * 24,
              child: WalletCardsList(),
            ),
            TransactionsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (context) => const WalletActionsBottomSheet(),
        ),
        child: SvgPicture.asset(
          'assets/icons/in_out_arrows.svg',
        ),
      ),
    );
  }
}
