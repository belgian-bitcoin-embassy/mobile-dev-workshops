import 'package:mobile_dev_workshops/features/reserved_amount_actions/reserved_amount_actions_bottom_sheet.dart';
import 'package:mobile_dev_workshops/services/wallets/impl/bitcoin_wallet_service.dart';
import 'package:mobile_dev_workshops/services/wallets/impl/lightning_wallet_service.dart';
import 'package:mobile_dev_workshops/services/wallets/wallet_service.dart';
import 'package:mobile_dev_workshops/view_models/reserved_amounts_list_item_view_model.dart';
import 'package:flutter/material.dart';

class ReservedAmountsListItem extends StatelessWidget {
  const ReservedAmountsListItem({
    super.key,
    required this.reservedAmount,
    required this.walletService,
    required this.savingsWalletService,
  });

  final ReservedAmountsListItemViewModel reservedAmount;
  final WalletService walletService;
  final BitcoinWalletService savingsWalletService;

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
                        savingsWalletService: savingsWalletService,
                      );
                    }
                    return const Text('Not implemented yet');
                  },
                );
              }
            : null);
  }
}
