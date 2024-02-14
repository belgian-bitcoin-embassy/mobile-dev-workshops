import 'package:bitcoin_flutter_app/features/wallet_actions/send/send_state.dart';
import 'package:bitcoin_flutter_app/services/wallet_service.dart';

class SendController {
  final SendState Function() _getState;
  final Function(SendState state) _updateState;
  final WalletService _bitcoinWalletService;

  SendController({
    required getState,
    required updateState,
    required bitcoinWalletService,
  })  : _getState = getState,
        _updateState = updateState,
        _bitcoinWalletService = bitcoinWalletService;

  void amountChangeHandler(String? amount) async {
    final state = _getState();
    try {
      if (amount == null || amount.isEmpty) {
        _updateState(state.copyWith(amountSat: 0, clearError: true));
      } else {
        final amountBtc = double.parse(amount);
        final int amountSat = (amountBtc * 100000000).round();

        if (amountSat > await _bitcoinWalletService.getSpendableBalanceSat()) {
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
      final fetchedRates = await (_bitcoinWalletService as BitcoinWalletService)
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

      final txId = await _bitcoinWalletService.pay(
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
}

class InvalidAmountException implements Exception {}

class NotEnoughFundsException implements Exception {}

class PaymentException implements Exception {}

class FeeRecommendationNotAvailableException implements Exception {}
