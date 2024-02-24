import 'package:bitcoin_flutter_app/enums/wallet_type.dart';
import 'package:bitcoin_flutter_app/view_models/reserved_amounts_list_item_view_model.dart';
import 'package:flutter/material.dart';

class ReservedAmountsListItem extends StatelessWidget {
  const ReservedAmountsListItem({
    super.key,
    required this.reservedAmount,
    required this.walletType,
  });

  final ReservedAmountsListItemViewModel reservedAmount;
  final WalletType walletType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: const CircleAvatar(
        child: Text('R'),
      ),
      title: Text(
        reservedAmount.isActionRequired
            ? 'Pending allocation'
            : 'Being processed',
        style: theme.textTheme.titleMedium,
      ),
      subtitle: reservedAmount.isActionRequired
          ? const Text('ⓘ Action Required')
          : null,
      trailing: Text(
        walletType == WalletType.onChain
            ? '${reservedAmount.amountBtc} BTC'
            : '${reservedAmount.amountSat} sats',
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
