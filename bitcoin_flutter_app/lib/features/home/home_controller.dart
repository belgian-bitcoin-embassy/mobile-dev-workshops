import 'package:bitcoin_flutter_app/features/home/home_state.dart';
import 'package:bitcoin_flutter_app/services/wallet_service.dart';
import 'package:bitcoin_flutter_app/view_models/wallet_balance_view_model.dart';

class HomeController {
  final HomeState Function() _getState;
  final Function(HomeState state) _updateState;
  final WalletService _bitcoinWalletService;

  static const walletName =
      'Savings'; // For a real app, the name should be dynamic and be set by the user when adding the wallet and stored in some local storage.

  HomeController({
    required getState,
    required updateState,
    required bitcoinWalletService,
  })  : _getState = getState,
        _updateState = updateState,
        _bitcoinWalletService = bitcoinWalletService;

  Future<void> init() async {
    if ((_bitcoinWalletService as BitcoinWalletService).hasWallet) {
      _updateState(
        _getState().copyWith(
          walletBalance: WalletBalanceViewModel(
            walletName: walletName,
            balanceSat: await _bitcoinWalletService.getSpendableBalanceSat(),
          ),
        ),
      );
    } else {
      _updateState(_getState().copyWith(clearWalletBalance: true));
    }
  }

  Future<void> addNewWallet() async {
    try {
      await _bitcoinWalletService.addWallet();
      _updateState(
        _getState().copyWith(
          walletBalance: WalletBalanceViewModel(
            walletName: walletName,
            balanceSat: await _bitcoinWalletService.getSpendableBalanceSat(),
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteWallet() async {
    try {
      await _bitcoinWalletService.deleteWallet();
      _updateState(_getState().copyWith(clearWalletBalance: true));
    } catch (e) {
      print(e);
    }
  }

  Future<void> refresh() async {
    try {
      final state = _getState();
      if (state.walletBalance == null) {
        // No wallet to refresh
        return;
      }

      await (_bitcoinWalletService as BitcoinWalletService).sync();
      final balance = await _bitcoinWalletService.getSpendableBalanceSat();
      _updateState(
        state.copyWith(
          walletBalance: WalletBalanceViewModel(
            walletName: state.walletBalance!.walletName,
            balanceSat: balance,
          ),
        ),
      );
    } catch (e) {
      print(e);
      // ToDo: handle and set error state
    }
  }
}
