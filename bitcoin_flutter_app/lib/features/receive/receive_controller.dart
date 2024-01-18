import 'package:bitcoin_flutter_app/features/receive/receive_state.dart';
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
    if (amount == null || amount.isEmpty) {
      _updateState(_getState().copyWith(amountSat: 0));
    } else {
      final amountBtc = double.parse(amount);
      final int amountSat = (amountBtc * 100000000).round();
      _updateState(_getState().copyWith(amountSat: amountSat));
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
      final invoice = '';
      //await _bitcoinWalletService.generateInvoice();
      _updateState(_getState().copyWith(bitcoinInvoice: invoice));
    } catch (e) {
      print(e);
    }
  }
}
