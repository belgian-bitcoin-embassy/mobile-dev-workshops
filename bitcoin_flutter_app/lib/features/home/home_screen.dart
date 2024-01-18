import 'package:bitcoin_flutter_app/constants.dart';
import 'package:bitcoin_flutter_app/features/home/home_controller.dart';
import 'package:bitcoin_flutter_app/features/home/home_state.dart';
import 'package:bitcoin_flutter_app/services/wallet_service.dart';
import 'package:bitcoin_flutter_app/widgets/transactions/transactions_list.dart';
import 'package:bitcoin_flutter_app/widgets/wallets/wallet_cards_list.dart';
import 'package:bitcoin_flutter_app/widgets/wallets/wallet_actions_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.bitcoinWalletService, super.key});

  final WalletService bitcoinWalletService;

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
      bitcoinWalletService: widget.bitcoinWalletService,
    );
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      endDrawer: const Drawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: kSpacingUnit * 24,
              child: WalletCardsList(
                _state.walletBalance == null ? [] : [_state.walletBalance!],
                onAddNewWallet: _controller.addNewWallet,
                onDeleteWallet: _controller.deleteWallet,
              ),
            ),
            const TransactionsList(),
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
