import 'package:bitcoin_flutter_app/enums/wallet_type.dart';
import 'package:bitcoin_flutter_app/features/wallet_actions/receive/receive_state.dart';
import 'package:bitcoin_flutter_app/services/wallet_service.dart';

class ReceiveController {
  final ReceiveState Function() _getState;
  final Function(ReceiveState state) _updateState;
  final List<WalletService> _walletServices;

  ReceiveController({
    required getState,
    required updateState,
    required walletServices,
  })  : _getState = getState,
        _updateState = updateState,
        _walletServices = walletServices {
    // Check which wallet service has a wallet and set the wallet type
    final availableWallets = _walletServices
        .where((service) => service.hasWallet)
        .map((service) => service.walletType)
        .toList();
    _updateState(_getState().copyWith(
      selectedWallet: availableWallets.first,
      availableWallets: availableWallets,
    ));
  }

  void onWalletTypeChange(WalletType wallet) {
    _updateState(_getState().copyWith(selectedWallet: wallet));
  }

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
      final state = _getState();
      _updateState(state.copyWith(isGeneratingInvoice: true));

      final (bitcoinInvoice, lightningInvoice) =
          await _selectedWalletService.generateInvoices(
        amountSat: state.amountSat,
        description: '${state.label} - ${state.message}',
      );
      _updateState(_getState().copyWith(
        bitcoinInvoice: bitcoinInvoice,
        lightningInvoice: lightningInvoice,
      ));
    } catch (e) {
      print(e);
    } finally {
      _updateState(_getState().copyWith(isGeneratingInvoice: false));
    }
  }

  void editInvoice() {
    final state = _getState();
    _updateState(
      ReceiveState(
        selectedWallet: state.selectedWallet,
        availableWallets: state.availableWallets,
      ),
    );
  }

  WalletService get _selectedWalletService {
    final selectedWallet = _getState().selectedWallet;
    return _walletServices.firstWhere(
      (service) => service.walletType == selectedWallet,
    );
  }
}
