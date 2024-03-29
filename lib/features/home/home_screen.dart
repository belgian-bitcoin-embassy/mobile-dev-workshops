import 'package:mobile_dev_workshops/constants.dart';
import 'package:mobile_dev_workshops/enums/wallet_type.dart';
import 'package:mobile_dev_workshops/features/home/home_controller.dart';
import 'package:mobile_dev_workshops/features/home/home_state.dart';
import 'package:mobile_dev_workshops/services/wallets/impl/bitcoin_wallet_service.dart';
import 'package:mobile_dev_workshops/services/wallets/wallet_service.dart';
import 'package:mobile_dev_workshops/widgets/reserved_amounts/reserved_amounts_list.dart';
import 'package:mobile_dev_workshops/widgets/transactions/transactions_list.dart';
import 'package:mobile_dev_workshops/widgets/wallets/wallet_cards_list.dart';
import 'package:mobile_dev_workshops/features/wallet_actions/wallet_actions_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.walletServices,
    super.key,
  });

  final List<WalletService> walletServices;

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
      walletServices: widget.walletServices,
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
                onSelectWallet: _controller.selectWallet,
                selectedWalletIndex: _state.walletIndex,
              ),
            ),
            ReservedAmountsList(
              reservedAmounts: _state.reservedAmountsLists.isNotEmpty
                  ? _state.reservedAmountsLists[_state.walletIndex]
                  : null,
              walletService: widget.walletServices[_state.walletIndex],
              savingsWalletService: widget.walletServices.firstWhere(
                      (service) => service.walletType == WalletType.onChain)
                  as BitcoinWalletService,
            ),
            TransactionsList(
              transactions: _state.transactionLists.isNotEmpty
                  ? _state.transactionLists[_state.walletIndex]
                  : null,
              walletType: _state.selectedWalletType,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => WalletActionsBottomSheet(
            walletServices: widget.walletServices,
          ),
        ),
        child: SvgPicture.asset(
          'assets/icons/in_out_arrows.svg',
        ),
      ),
    );
  }
}
