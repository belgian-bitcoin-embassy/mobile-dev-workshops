import 'package:bitcoin_flutter_app/enums/wallet_type.dart';
import 'package:bitcoin_flutter_app/features/wallet_actions/receive/receive_state.dart';
import 'package:bitcoin_flutter_app/services/wallet_service.dart';

class ReceiveController {
  final ReceiveState Function() _getState;
  final Function(ReceiveState state) _updateState;
  final WalletService _bitcoinWalletService;

  ReceiveController({
    required getState,
    required updateState,
    required bitcoinWalletService,
  })  : _getState = getState,
        _updateState = updateState,
        _bitcoinWalletService = bitcoinWalletService;

  void amountChangeHandler(String? amount) async {
    try {
      if (amount == null || amount.isEmpty) {
        _updateState(
            _getState().copyWith(amountSat: 0, isInvalidAmount: false));
      } else {
        final amountBtc = double.parse(amount);
        final int amountSat = (amountBtc * 100000000).round();
        _updateState(
            _getState().copyWith(amountSat: amountSat, isInvalidAmount: false));
      }
    } catch (e) {
      print(e);
      _updateState(_getState().copyWith(isInvalidAmount: true));
    }
  }

  void labelChangeHandler(String? label) async {
    if (label == null || label.isEmpty) {
      _updateState(_getState().copyWith(label: ''));
    } else {
      _updateState(_getState().copyWith(label: label));
    }
  }

  void messageChangeHandler(String? message) async {
    if (message == null || message.isEmpty) {
      _updateState(_getState().copyWith(message: ''));
    } else {
      _updateState(_getState().copyWith(message: message));
    }
  }

  Future<void> generateInvoice() async {
    try {
      _updateState(_getState().copyWith(isGeneratingInvoice: true));

      final (bitcoinInvoice, _) =
          await _bitcoinWalletService.generateInvoices();
      _updateState(_getState().copyWith(bitcoinInvoice: bitcoinInvoice));
    } catch (e) {
      print(e);
    } finally {
      _updateState(_getState().copyWith(isGeneratingInvoice: false));
    }
  }

  void editInvoice() {
    _updateState(const ReceiveState());
  }
}
