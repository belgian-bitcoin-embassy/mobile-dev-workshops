import 'package:bitcoin_flutter_app/constants.dart';
import 'package:bitcoin_flutter_app/widgets/buttons/icon_label_stacked_button.dart';
import 'package:flutter/material.dart';

class WalletActionsBottomSheet extends StatelessWidget {
  const WalletActionsBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kSpacingUnit * 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet actions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconLabelStackedButton(
                icon: Icons.arrow_downward,
                label: 'Receive funds',
                onPressed: () {
                  print('Receive funds');
                },
              ),
              IconLabelStackedButton(
                icon: Icons.arrow_upward,
                label: 'Send funds',
                onPressed: () {
                  print('Send funds');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
