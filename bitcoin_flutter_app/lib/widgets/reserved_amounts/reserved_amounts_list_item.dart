import 'package:bitcoin_flutter_app/features/reserved_amount_actions/reserved_amount_actions_bottom_sheet.dart';
import 'package:bitcoin_flutter_app/services/wallet_service.dart';
import 'package:bitcoin_flutter_app/view_models/reserved_amounts_list_item_view_model.dart';
import 'package:flutter/material.dart';

class ReservedAmountsListItem extends StatelessWidget {
  const ReservedAmountsListItem({
    super.key,
    required this.reservedAmount,
    required this.walletService,
  });

  final ReservedAmountsListItemViewModel reservedAmount;
  final WalletService walletService;
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
          walletService is LightningWalletService
              ? '${reservedAmount.amountSat} sats'
              : '${reservedAmount.amountBtc} BTC',
          style: theme.textTheme.bodyMedium,
        ),
        onTap: reservedAmount.isActionRequired
            ? () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) {
                    if (walletService is LightningWalletService) {
                      return ReservedAmountActionsBottomSheet(
                        walletService: walletService as LightningWalletService,
                      );
                    }
                    return const Text('Not implemented yet');
                  },
                );
              }
            : null);
  }
}
