import 'package:bitcoin_flutter_app/constants.dart';
import 'package:bitcoin_flutter_app/features/home/home_controller.dart';
import 'package:bitcoin_flutter_app/features/home/home_state.dart';
import 'package:bitcoin_flutter_app/services/wallet_service.dart';
import 'package:bitcoin_flutter_app/widgets/transactions/transactions_list.dart';
import 'package:bitcoin_flutter_app/widgets/wallets/wallet_cards_list.dart';
import 'package:bitcoin_flutter_app/features/wallet_actions/wallet_actions_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.bitcoinWalletService,
    super.key,
  });

  final BitcoinWalletService bitcoinWalletService;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  HomeState _state = const HomeState();
  late HomeController _controller;

  @override
  void initState() {
    super.initState();

    _controller = HomeController(
      getState: () => _state,
      updateState: (HomeState state) => setState(() => _state = state),
      walletServices: [
        widget.bitcoinWalletService,
      ],
    );
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      endDrawer: const Drawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await _controller.refresh();
        },
        child: ListView(
          children: [
            SizedBox(
              height: kSpacingUnit * 24,
              child: WalletCardsList(
                _state.walletBalances,
                onAddNewWallet: _controller.addNewWallet,
                onDeleteWallet: _controller.deleteWallet,
              ),
            ),
            TransactionsList(
              transactions: _state.transactionLists.isNotEmpty
                  ? _state.transactionLists[_state.transactionListIndex]
                  : null,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => WalletActionsBottomSheet(
            bitcoinWalletService: widget.bitcoinWalletService,
          ),
        ),
        child: SvgPicture.asset(
          'assets/icons/in_out_arrows.svg',
        ),
      ),
    );
  }
}
