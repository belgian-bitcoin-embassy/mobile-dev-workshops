import 'package:bitcoin_flutter_app/enums/wallet_type.dart';
import 'package:bitcoin_flutter_app/features/wallet_actions/send/send_state.dart';
import 'package:bitcoin_flutter_app/services/wallet_service.dart';

class SendController {
  final SendState Function() _getState;
  final Function(SendState state) _updateState;
  final List<WalletService> _walletServices;

  SendController({
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

  void onWalletTypeChange(WalletType selectedWallet) {
    _updateState(_getState().copyWith(selectedWallet: selectedWallet));
  }

  void amountChangeHandler(String? amount) async {
    final state = _getState();
    try {
      if (amount == null || amount.isEmpty) {
        _updateState(state.copyWith(clearAmountSat: true, clearError: true));
      } else {
        final amountBtc = double.parse(amount);
        final int amountSat = (amountBtc * 100000000).round();

        if (amountSat > await _selectedWalletService.getSpendableBalanceSat()) {
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

  void invoiceChangeHandler(String? invoice) async {
    if (invoice == null || invoice.isEmpty) {
      _updateState(_getState().copyWith(invoice: ''));
    } else {
      _updateState(_getState().copyWith(invoice: invoice));
    }
  }

  Future<void> fetchRecommendedFeeRates() async {
    final state = _getState();
    try {
      if (_selectedWalletService is BitcoinWalletService) {
        final fetchedRates =
            await (_selectedWalletService as BitcoinWalletService)
                .calculateFeeRates();

        final recommendedFeeRates = {
          fetchedRates.highPriority,
          fetchedRates.mediumPriority,
          fetchedRates.lowPriority,
          fetchedRates.noPriority
        }.toList();

        _updateState(
          state.copyWith(
            recommendedFeeRates: recommendedFeeRates,
            satPerVbyte: fetchedRates.mediumPriority,
          ),
        );
      }
    } catch (e) {
      print(e);
      _updateState(state.copyWith(
        error: FeeRecommendationNotAvailableException(),
      ));
    }
  }

  void feeRateChangeHandler(double feeRate) {
    _updateState(_getState().copyWith(satPerVbyte: feeRate));
  }

  Future<void> makePayment() async {
    final state = _getState();
    try {
      _updateState(state.copyWith(isMakingPayment: true));

      final txId = await _selectedWalletService.pay(
        state.invoice!,
        amountSat: state.amountSat,
        satPerVbyte: state.satPerVbyte,
      );

      _updateState(state.copyWith(
        isMakingPayment: false,
        txId: txId,
      ));
    } catch (e) {
      print(e);
      _updateState(state.copyWith(
        isMakingPayment: false,
        error: PaymentException(),
      ));
    }
  }

  WalletService get _selectedWalletService {
    final selectedWallet = _getState().selectedWallet;
    return _walletServices.firstWhere(
      (service) => service.walletType == selectedWallet,
    );
  }
}

class InvalidAmountException implements Exception {}

class NotEnoughFundsException implements Exception {}

class PaymentException implements Exception {}

class FeeRecommendationNotAvailableException implements Exception {}
