import 'package:bitcoin_flutter_app/constants.dart';
import 'package:bitcoin_flutter_app/enums/wallet_type.dart';
import 'package:flutter/material.dart';

class AddNewWalletCard extends StatelessWidget {
  const AddNewWalletCard({
    required this.walletType,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final WalletType walletType;
  final Function(WalletType) onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(kSpacingUnit),
        onTap: () => onPressed(walletType),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add,
            ),
            Text('Add wallet: ${walletType.label}'),
          ],
        ),
      ),
    );
  }
}
