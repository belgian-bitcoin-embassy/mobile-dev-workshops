import 'package:bitcoin_flutter_app/enums/wallet_type.dart';
import 'package:bitcoin_flutter_app/view_models/transactions_list_item_view_model.dart';
import 'package:flutter/material.dart';

class TransactionsListItem extends StatelessWidget {
  const TransactionsListItem({
    super.key,
    required this.transaction,
    required this.walletType,
  });

  final TransactionsListItemViewModel transaction;
  final WalletType walletType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        child: Icon(
          transaction.isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
        ),
      ),
      title: Text(
        transaction.isIncoming ? 'Received funds' : 'Sent funds',
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        transaction.formattedTimestamp != null
            ? transaction.formattedTimestamp!
            : walletType == WalletType.onChain
                ? 'Pending'
                : '',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Text(
          '${transaction.isIncoming ? '+' : ''}${walletType == WalletType.onChain ? '${transaction.amountBtc} BTC' : '${transaction.amountSat} sats'}',
          style: theme.textTheme.bodyMedium),
    );
  }
}
