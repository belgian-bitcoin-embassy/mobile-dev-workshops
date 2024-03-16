import 'package:mobile_dev_workshops/enums/wallet_type.dart';
import 'package:mobile_dev_workshops/view_models/transactions_list_item_view_model.dart';
import 'package:mobile_dev_workshops/widgets/transactions/transactions_list_item.dart';
import 'package:flutter/material.dart';

class TransactionsList extends StatelessWidget {
  const TransactionsList({
    super.key,
    required this.transactions,
    required this.walletType,
  });

  final List<TransactionsListItemViewModel>? transactions;
  final WalletType walletType;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Transactions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap:
              true, // To set constraints on the ListView in an infinite height parent (ListView in HomeScreen)
          physics:
              const NeverScrollableScrollPhysics(), // Scrolling is handled by the parent (ListView in HomeScreen)
          itemBuilder: (ctx, index) {
            return TransactionsListItem(
              transaction: transactions![index],
              walletType: walletType,
            );
          },
          itemCount: transactions == null ? 0 : transactions!.length,
        ),
      ],
    );
  }
}
