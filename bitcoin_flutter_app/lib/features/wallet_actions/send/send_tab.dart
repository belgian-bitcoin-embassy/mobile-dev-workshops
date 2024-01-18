import 'package:bitcoin_flutter_app/constants.dart';
import 'package:flutter/material.dart';

class SendTab extends StatelessWidget {
  const SendTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: kSpacingUnit * 2),
        // Amount Field
        const SizedBox(
          width: 250,
          child: TextField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Amount',
              hintText: '0',
              helperText: 'The amount you want to send in BTC.',
            ),
            onChanged: null,
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Invoice Field
        const SizedBox(
          width: 250,
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Invoice',
              hintText: '1bc1q2c3...',
              helperText: 'The invoice to pay.',
            ),
            onChanged: null,
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
        const SizedBox(
          height: kSpacingUnit * 2,
          child: Text(
            false
                ? 'Please enter a valid amount.'
                : true
                    ? 'Not enough funds available.'
                    : false
                        ? 'Please enter a valid invoice.'
                        : '',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Send funds Button
        ElevatedButton.icon(
          onPressed: null,
          label: const Text('Send funds'),
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }
}
