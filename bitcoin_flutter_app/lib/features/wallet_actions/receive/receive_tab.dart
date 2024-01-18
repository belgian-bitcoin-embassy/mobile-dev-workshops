import 'package:bitcoin_flutter_app/constants.dart';
import 'package:flutter/material.dart';

class ReceiveTab extends StatelessWidget {
  const ReceiveTab({super.key});

  @override
  Widget build(BuildContext context) {
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
              labelText: 'Amount (optional)',
              hintText: '0',
              helperText: 'The amount you want to receive in BTC.',
            ),
            onChanged: null,
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Label Field
        const SizedBox(
          width: 250,
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Label (optional)',
              hintText: 'Alice',
              helperText: 'A name the payer knows you by.',
            ),
            onChanged: null,
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Message Field
        const SizedBox(
          width: 250,
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Message (optional)',
              hintText: 'Payback for dinner.',
              helperText: 'A note to the payer.',
            ),
            onChanged: null,
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Error message
        const SizedBox(
          height: kSpacingUnit * 2,
          child: Text(
            true
                ? 'You need to create a wallet first.'
                : false
                    ? 'Please enter a valid amount.'
                    : '',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Generate invoice Button
        ElevatedButton.icon(
          onPressed: null,
          label: const Text('Generate invoice'),
          icon: const Icon(Icons.qr_code),
        ),
      ],
    );
  }
}
