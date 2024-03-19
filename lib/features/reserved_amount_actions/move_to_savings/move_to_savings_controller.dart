import 'package:mobile_dev_workshops/features/reserved_amount_actions/move_to_savings/move_to_savings_state.dart';
import 'package:mobile_dev_workshops/services/wallets/impl/bitcoin_wallet_service.dart';
import 'package:mobile_dev_workshops/services/wallets/impl/lightning_wallet_service.dart';

class MoveToSavingsController {
  final MoveToSavingsState Function() _getState;
  final Function(MoveToSavingsState state) _updateState;
  final LightningWalletService _walletService;
  final BitcoinWalletService _savingsWalletService;

  MoveToSavingsController({
    required getState,
    required updateState,
    required walletService,
    required savingsWalletService,
  })  : _getState = getState,
        _updateState = updateState,
        _walletService = walletService,
        _savingsWalletService = savingsWalletService;

  Future<void> fetchSavingsAddress() async {
    final (address, _) = await _savingsWalletService.generateInvoices();
    _updateState(_getState().copyWith(address: address));
  }

  void amountChangeHandler(String? amount) async {
    final state = _getState();
    try {
      if (amount == null || amount.isEmpty) {
        _updateState(state.copyWith(clearAmountSat: true, clearError: true));
      } else {
        final amountSat = int.parse(amount);

        if (amountSat > await _walletService.spendableOnChainBalanceSat) {
          _updateState(state.copyWith(
            error: NotEnoughFundsException(),
          ));
        } else {
          _updateState(state.copyWith(amountSat: amountSat, clearError: true));
        }
      }
    } catch (e) {
      print(e);
      _updateState(state.copyWith(
        error: InvalidAmountException(),
      ));
    }
  }

  Future<void> confirm() async {
    final state = _getState();
    _updateState(state.copyWith(isMovingToSavings: true));
    try {
      final txId = await _walletService.sendOnChainFunds(
        state.address!,
        state.amountSat!,
      );
      _updateState(state.copyWith(txId: txId, isMovingToSavings: false));
    } catch (e) {
      print(e);
      _updateState(state.copyWith(
        error: FailedToMoveToSavingsError(e.toString()),
        isMovingToSavings: false,
      ));
    }
  }

  Future<void> drain() async {
    final state = _getState();
    _updateState(state.copyWith(isMovingToSavings: true));
    try {
      final txId = await _walletService.drainOnChainFunds(
        state.address!,
      );
      _updateState(state.copyWith(
        txId: txId,
        isMovingToSavings: false,
      ));
    } catch (e) {
      print(e);
      _updateState(state.copyWith(
        error: FailedToMoveToSavingsError(e.toString()),
        isMovingToSavings: false,
      ));
    }
  }
}

class NoAmountError implements Exception {
  const NoAmountError(this.message);

  final String message;
}

class FailedToMoveToSavingsError implements Exception {
  const FailedToMoveToSavingsError(this.message);

  final String message;
}

class NotEnoughFundsException implements Exception {}

class InvalidAmountException implements Exception {}
