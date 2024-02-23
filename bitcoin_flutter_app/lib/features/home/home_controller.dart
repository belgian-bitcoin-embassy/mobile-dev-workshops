import 'package:bitcoin_flutter_app/enums/wallet_type.dart';
import 'package:bitcoin_flutter_app/features/home/home_state.dart';
import 'package:bitcoin_flutter_app/services/wallet_service.dart';
import 'package:bitcoin_flutter_app/view_models/transactions_list_item_view_model.dart';
import 'package:bitcoin_flutter_app/view_models/wallet_balance_view_model.dart';

class HomeController {
  final HomeState Function() _getState;
  final Function(HomeState state) _updateState;
  final List<WalletService> _walletServices;

  HomeController({
    required getState,
    required updateState,
    required walletServices,
  })  : _getState = getState,
        _updateState = updateState,
        _walletServices = walletServices;

  Future<void> init() async {
    final walletBalances = <WalletBalanceViewModel>[];
    final transactionLists = <List<TransactionsListItemViewModel>?>[];
    for (int i = 0; i < _walletServices.length; i++) {
      final service = _walletServices[i];
      walletBalances.add(
        WalletBalanceViewModel(
          walletType: service.walletType,
          balanceSat:
              service.hasWallet ? await service.getSpendableBalanceSat() : null,
        ),
      );
      transactionLists.add(
        service.hasWallet ? await _getTransactions(service) : null,
      );
    }

    _updateState(_getState().copyWith(
      walletBalances: walletBalances,
      transactionLists: transactionLists,
    ));
  }

  Future<void> addNewWallet(WalletType walletType) async {
    final walletIndex = _walletServices.indexWhere(
      (service) => service.walletType == walletType,
    );
    final walletService = _walletServices[walletIndex];
    final state = _getState();
    try {
      await walletService.addWallet();
      _updateState(
        state.copyWith(
          walletBalances: state.walletBalances
            ..[walletIndex] = WalletBalanceViewModel(
              walletType: walletService.walletType,
              balanceSat: await walletService.getSpendableBalanceSat(),
            ),
          transactionListIndex: walletIndex,
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteWallet(int index) async {
    try {
      await _walletServices[index].deleteWallet();
      final state = _getState();
      _updateState(
        state.copyWith(
          walletBalances: state.walletBalances
            ..[index] = WalletBalanceViewModel(
              walletType: state.walletBalances[index].walletType,
              balanceSat: null,
            ),
          transactionLists: state.transactionLists..[index] = null,
          transactionListIndex: index - 1 < 0 ? 0 : index - 1,
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> refresh() async {
    try {
      final state = _getState();
      for (int i = 0; i < _walletServices.length; i++) {
        final walletService = _walletServices[i];
        if (walletService.hasWallet) {
          await walletService.sync();
          final balance = await walletService.getSpendableBalanceSat();
          _updateState(
            state.copyWith(
              walletBalances: state.walletBalances
                ..[i] = WalletBalanceViewModel(
                  walletType: state.walletBalances[i].walletType,
                  balanceSat: balance,
                ),
              transactionLists: state.transactionLists
                ..[i] = await _getTransactions(walletService),
            ),
          );
        }
      }
    } catch (e) {
      print(e);
      // ToDo: handle and set error state
    }
  }

  void selectWallet(int index) {
    _updateState(_getState().copyWith(transactionListIndex: index));
  }

  Future<List<TransactionsListItemViewModel>> _getTransactions(
    WalletService wallet,
  ) async {
    // Get transaction entities from the wallet
    final transactionEntities = await wallet.getTransactions();
    // Map transaction entities to view models
    final transactions = transactionEntities
        .map((entity) =>
            TransactionsListItemViewModel.fromTransactionEntity(entity))
        .toList();
    // Sort transactions by timestamp in descending order
    transactions.sort((t1, t2) {
      if (t1.timestamp == null && t2.timestamp == null) {
        return 0;
      }
      if (t1.timestamp == null) {
        return -1;
      }
      if (t2.timestamp == null) {
        return 1;
      }
      return t2.timestamp!.compareTo(t1.timestamp!);
    });
    return transactions;
  }
}
