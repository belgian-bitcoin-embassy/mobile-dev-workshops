import 'package:bitcoin_flutter_app/features/home/home_state.dart';
import 'package:bitcoin_flutter_app/services/wallet_service.dart';
import 'package:bitcoin_flutter_app/view_models/transactions_list_item_view_model.dart';
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
          transactions: await _getTransactions(),
        ),
      );
    } else {
      _updateState(_getState().copyWith(
        clearWalletBalance: true,
        transactions: [],
      ));
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
          transactions: await _getTransactions(),
        ),
      );
    } catch (e) {
      print(e);
      // ToDo: handle and set error state
    }
  }

  Future<List<TransactionsListItemViewModel>> _getTransactions() async {
    // Get transaction entities from the wallet
    final transactionEntities = await _bitcoinWalletService.getTransactions();
    // Map transaction entities to view models
    final transactions = transactionEntities
        .map((entity) =>
            TransactionsListItemViewModel.fromTransactionEntity(entity))
        .toList();
    // Sort transactions by timestamp in descending order
    transactions.sort((t1, t2) => t2.timestamp.compareTo(t1.timestamp));
    return transactions;
  }
}
