import 'package:flutter/material.dart';

class TransactionsListItem extends StatelessWidget {
  const TransactionsListItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.arrow_downward),
      ),
      title: Text('Received funds', style: theme.textTheme.titleMedium),
      subtitle: Text('14-02-2021 12:00', style: theme.textTheme.bodySmall),
      trailing: Text('+0.00000001 BTC', style: theme.textTheme.bodyMedium),
    );
  }
}
