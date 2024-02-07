import 'package:bitcoin_flutter_app/constants.dart';
import 'package:bitcoin_flutter_app/features/wallet_actions/send/send_controller.dart';
import 'package:bitcoin_flutter_app/features/wallet_actions/send/send_state.dart';
import 'package:bitcoin_flutter_app/services/wallet_service.dart';
import 'package:flutter/material.dart';

class SendTab extends StatefulWidget {
  const SendTab({required this.bitcoinWalletService, super.key});

  final WalletService bitcoinWalletService;

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
      bitcoinWalletService: widget.bitcoinWalletService,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: kSpacingUnit * 2),
        // Amount Field
        SizedBox(
          width: 250,
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Amount',
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
        const SizedBox(height: kSpacingUnit * 2),
        // Fee rate slider
        SizedBox(
          width: 250,
          child: Column(
            children: [
              const Slider(
                value: 0.5,
                onChanged: null,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: kSpacingUnit * 1.5),
                child: Text(
                  'The fee rate (sat/vB) to pay for this transaction.',
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
          onPressed: _state.amountSat == null ||
                  _state.amountSat == 0 ||
                  _state.invoice == null ||
                  _state.invoice!.isEmpty ||
                  _state.error is InvalidAmountException ||
                  _state.error is NotEnoughFundsException ||
                  _state.isMakingPayment
              ? null
              : _controller.makePayment,
          label: const Text('Send funds'),
          icon: _state.isMakingPayment
              ? const CircularProgressIndicator()
              : const Icon(Icons.send),
        ),
      ],
    );
  }
}
