import 'package:bitcoin_flutter_app/constants.dart';
import 'package:bitcoin_flutter_app/features/reserved_amount_actions/move_to_savings/move_to_savings_controller.dart';
import 'package:bitcoin_flutter_app/features/reserved_amount_actions/move_to_savings/move_to_savings_state.dart';
import 'package:bitcoin_flutter_app/services/wallet_service.dart';
import 'package:flutter/material.dart';

class MoveToSavingsTab extends StatefulWidget {
  const MoveToSavingsTab({
    super.key,
    required this.walletService,
    required this.savingsWalletService,
  });

  final LightningWalletService walletService;
  final BitcoinWalletService savingsWalletService;

  @override
  MoveToSavingsTabState createState() => MoveToSavingsTabState();
}

class MoveToSavingsTabState extends State<MoveToSavingsTab> {
  MoveToSavingsState _state = const MoveToSavingsState();
  late MoveToSavingsController _controller;

  @override
  void initState() {
    super.initState();

    _controller = MoveToSavingsController(
      getState: () => _state,
      updateState: (MoveToSavingsState state) => setState(() => _state = state),
      walletService: widget.walletService,
      savingsWalletService: widget.savingsWalletService,
    );

    _controller.fetchSavingsAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: kSpacingUnit * 2),
        // Address to send to
        ListTile(
          title: const Text('Savings Address'),
          subtitle: Text(_state.address ?? 'Loading...'),
        ),
        // Amount
        const SizedBox(height: kSpacingUnit * 2),
        TextField(
          onChanged: _controller.amountChangeHandler,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Amount',
            hintText: '0',
            helperText: 'The amount of sats to move to savings.',
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Error message
        SizedBox(
          height: kSpacingUnit * 2,
          child: Text(
            _state.error is NoAmountError ||
                    _state.error is InvalidAmountException
                ? 'Please enter a valid amount.'
                : _state.error is NotEnoughFundsException
                    ? 'Not enough funds to move the amount to savings.'
                    : _state.error is FailedToMoveToSavingsError
                        ? 'Failed to move funds to savings. Please try again.'
                        : '',
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Send funds Button
        ElevatedButton.icon(
          onPressed: _state.isMovingToSavings
              ? null
              : () => _controller.confirm().then(
                    (_) {
                      if (_state.partialTxId != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Moved successfully. TxId: ${_state.partialTxId}'),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
          label: const Text('Move amount to savings'),
          icon: _state.isMovingToSavings
              ? const CircularProgressIndicator()
              : const Icon(Icons.move_up),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        TextButton(
            onPressed: _state.isMovingToSavings
                ? null
                : () => _controller.drain().then(
                      (_) {
                        if (_state.partialTxId != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Moved successfully. TxId: ${_state.partialTxId}'),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                    ),
            child: const Text('Drain all to savings')),
      ],
    );
  }
}
