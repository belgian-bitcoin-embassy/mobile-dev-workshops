import 'package:bitcoin_flutter_app/features/home/home_state.dart';
import 'package:bitcoin_flutter_app/services/wallet_service.dart';
import 'package:bitcoin_flutter_app/view_models/wallet_balance.dart';

class HomeController {
  final HomeState Function() _getState;
  final Function(HomeState state) _updateState;
  final WalletService _walletService;

  HomeController({
    required getState,
    required updateState,
    required walletService,
  })  : _getState = getState,
        _updateState = updateState,
        _walletService = walletService;

  /*Future<void> refresh() async {
    try {} catch (e) {
      if (e is NoWalletException) {
        _updateState(_getState().copyWith(clearWalletBalance: true));
      }
    }
  }*/

  Future<void> addNewWallet() async {
    try {
      await _walletService.addWallet();
      _updateState(
        _getState().copyWith(
          walletBalance: const WalletBalance(
            walletName: 'Savings',
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteWallet() async {
    try {
      await _walletService.deleteWallet();
      _updateState(_getState().copyWith(clearWalletBalance: true));
    } catch (e) {
      print(e);
    }
  }
}
