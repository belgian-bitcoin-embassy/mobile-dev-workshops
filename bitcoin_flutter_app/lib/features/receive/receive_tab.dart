import 'package:bitcoin_flutter_app/constants.dart';
import 'package:bitcoin_flutter_app/features/receive/receive_controller.dart';
import 'package:bitcoin_flutter_app/features/receive/receive_state.dart';
import 'package:bitcoin_flutter_app/services/wallet_service.dart';
import 'package:flutter/material.dart';

class ReceiveTab extends StatefulWidget {
  const ReceiveTab({required this.bitcoinWalletService, super.key});

  final WalletService bitcoinWalletService;

  @override
  ReceiveTabState createState() => ReceiveTabState();
}

class ReceiveTabState extends State<ReceiveTab> {
  ReceiveState _state = const ReceiveState();
  late ReceiveController _controller;

  @override
  void initState() {
    super.initState();

    _controller = ReceiveController(
      getState: () => _state,
      updateState: (ReceiveState state) => setState(() => _state = state),
      bitcoinWalletService: widget.bitcoinWalletService,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Todo: add amount, label and message fields and a button to generate a new address
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Amount Field
        SizedBox(
          width: 250,
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Amount (optional)',
              hintText: '0.00000001',
              helperText: 'The amount you want to receive in BTC.',
            ),
            onChanged: _controller.amountChangeHandler,
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),

        // Label Field
        SizedBox(
          width: 250,
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Label (optional)',
              hintText: 'Alice',
              helperText:
                  'A name the payer knows you by so he knows who he is sending to.',
            ),
            onChanged: _controller.labelChangeHandler,
          ),
        ),
        const SizedBox(height: 16),

        // Message Field
        SizedBox(
          width: 250,
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Message (optional)',
              hintText: 'Payback for dinner.',
              helperText: 'A note to the payer.',
            ),
            onChanged: _controller.messageChangeHandler,
          ),
        ),
        const SizedBox(height: 16),

        // Generate invoice Button
        ElevatedButton.icon(
          onPressed: () {
            // Call the controller method to generate address with inputs
            _controller.generateInvoice();
          },
          label: const Text('Generate invoice'),
          icon: const Icon(Icons.qr_code),
        ),
      ],
    );
  }
}
