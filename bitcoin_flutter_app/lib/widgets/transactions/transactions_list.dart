import 'package:bitcoin_flutter_app/widgets/transactions/transaction_list_item.dart';
import 'package:flutter/material.dart';

class TransactionsList extends StatelessWidget {
  const TransactionsList({super.key});

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
              true, // To set constraints on the ListView in an infinite height parent (SingleChildScrollView)
          physics:
              const NeverScrollableScrollPhysics(), // Scrolling is handled by the parent (SingleChildScrollView)
          itemBuilder: (ctx, index) {
            return const TransactionListItem();
          },
          itemCount: 10,
        ),
      ],
    );
  }
}
