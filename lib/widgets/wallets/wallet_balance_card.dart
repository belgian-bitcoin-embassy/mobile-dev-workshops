import 'package:bitcoin_flutter_app/constants.dart';
import 'package:bitcoin_flutter_app/enums/wallet_type.dart';
import 'package:bitcoin_flutter_app/view_models/wallet_balance_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard(
    this.walletBalance, {
    super.key,
    required this.onDelete,
    required this.onTap,
    required this.isSelected,
  });

  final WalletBalanceViewModel walletBalance;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kSpacingUnit),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        borderRadius: BorderRadius.circular(kSpacingUnit),
        onTap: onTap,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: kSpacingUnit * 12,
                  width: double.infinity,
                  color: theme.colorScheme.primaryContainer,
                  child: SvgPicture.asset(
                    walletBalance.walletType == WalletType.onChain
                        ? 'assets/icons/bitcoin_savings.svg'
                        : 'assets/icons/lightning_spending.svg',
                    fit: BoxFit
                        .none, // Don't scale the SVG, keep it at its original size
                  ),
                ),
                // Expanded to take up all the space of the height the list is constrained to
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(kSpacingUnit),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          walletBalance.walletType.label,
                          style: theme.textTheme.labelMedium,
                        ),
                        const SizedBox(height: kSpacingUnit),
                        Text(
                          walletBalance.walletType == WalletType.onChain
                              ? '${walletBalance.balanceBtc} BTC'
                              : '${walletBalance.balanceSat} sats',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        if (isSelected)
                          Container(
                            height: kSpacingUnit / 2,
                            width: double.infinity,
                            color: theme.colorScheme.onBackground,
                          ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: CloseButton(
                onPressed: onDelete,
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                    EdgeInsets.zero,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  iconSize: MaterialStateProperty.all(
                    kSpacingUnit * 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
