import 'package:mobile_dev_workshops/constants.dart';
import 'package:mobile_dev_workshops/enums/wallet_type.dart';
import 'package:mobile_dev_workshops/features/wallet_actions/send/send_controller.dart';
import 'package:mobile_dev_workshops/features/wallet_actions/send/send_state.dart';
import 'package:mobile_dev_workshops/services/wallets/wallet_service.dart';
import 'package:mobile_dev_workshops/widgets/wallets/wallet_selection_field.dart';
import 'package:flutter/material.dart';

class SendTab extends StatefulWidget {
  const SendTab({required this.walletServices, super.key});

  final List<WalletService> walletServices;

  @override
  SendTabState createState() => SendTabState();
}

class SendTabState extends State<SendTab> {
  SendState _state = const SendState();
  late SendController _controller;

  @override
  void initState() {
    super.initState();

    _controller = SendController(
      getState: () => _state,
      updateState: (SendState state) => setState(() => _state = state),
      walletServices: widget.walletServices,
    );

    _controller.fetchRecommendedFeeRates();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: kSpacingUnit * 2),
        WalletSelectionField(
          selectedWallet: _state.selectedWallet,
          availableWallets: _state.availableWallets,
          onWalletTypeChange: _controller.onWalletTypeChange,
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Amount Field
        SizedBox(
          width: 250,
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: _state.selectedWallet == WalletType.lightning
                  ? 'Amount (optional)'
                  : 'Amount',
              hintText: '0',
              helperText: 'The amount you want to send in BTC.',
            ),
            onChanged: _controller.amountChangeHandler,
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Invoice Field
        SizedBox(
          width: 250,
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Invoice',
              hintText: '1bc1q2c3...',
              helperText: 'The invoice to pay.',
            ),
            onChanged: _controller.invoiceChangeHandler,
          ),
        ),
        // Fee rate slider
        if (_state.selectedWallet == WalletType.onChain)
          _state.recommendedFeeRates == null
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: 250,
                  child: Column(
                    children: [
                      const SizedBox(height: kSpacingUnit * 2),
                      Slider(
                        value: _state.satPerVbyte ?? 0,
                        onChanged: _controller.feeRateChangeHandler,
                        divisions: _state.recommendedFeeRates!.length - 1 > 0
                            ? _state.recommendedFeeRates!.length - 1
                            : 1,
                        min: _state.recommendedFeeRates!.last,
                        max: _state.recommendedFeeRates!.first,
                        label: _state.satPerVbyte! <=
                                _state.recommendedFeeRates!.last
                            ? 'low priority'
                            : _state.satPerVbyte! >=
                                    _state.recommendedFeeRates!.first
                                ? 'high priority'
                                : 'medium priority',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: kSpacingUnit * 1.5,
                        ),
                        child: Text(
                          'The fee rate to pay for this transaction: ${_state.satPerVbyte ?? 0} sat/vB.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
        const SizedBox(height: kSpacingUnit * 2),
        // Error message
        SizedBox(
          height: kSpacingUnit * 2,
          child: Text(
            _state.error is InvalidAmountException
                ? 'Please enter a valid amount.'
                : _state.error is NotEnoughFundsException
                    ? 'Not enough funds available.'
                    : _state.error is PaymentException
                        ? 'Failed to make payment. Please try again.'
                        : '',
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Send funds Button
        ElevatedButton.icon(
          onPressed: _state.selectedWallet == WalletType.onChain &&
                      (_state.amountSat == null || _state.amountSat == 0) ||
                  _state.invoice == null ||
                  _state.invoice!.isEmpty ||
                  _state.error is InvalidAmountException ||
                  _state.error is NotEnoughFundsException ||
                  _state.isMakingPayment
              ? null
              : () => _controller.makePayment().then(
                    (_) {
                      if (_state.txId != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Payment successful. Tx ID: ${_state.partialTxId}'),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
          label: const Text('Send funds'),
          icon: _state.isMakingPayment
              ? const CircularProgressIndicator()
              : const Icon(Icons.send),
        ),
      ],
    );
  }
}
