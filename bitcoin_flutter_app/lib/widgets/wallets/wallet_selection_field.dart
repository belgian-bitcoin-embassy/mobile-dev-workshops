import 'package:bitcoin_flutter_app/constants.dart';
import 'package:bitcoin_flutter_app/enums/wallet_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WalletSelectionField extends StatelessWidget {
  const WalletSelectionField({
    super.key,
    required this.selectedWalletType,
    required this.onWalletTypeChange,
  });

  final WalletType selectedWalletType;
  final Function(WalletType) onWalletTypeChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: kSpacingUnit,
            vertical: kSpacingUnit * 2,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.secondary,
            ),
            borderRadius: BorderRadius.circular(kSpacingUnit / 2),
          ),
          width: 250,
          child: Row(
            children: [
              SvgPicture.asset(
                selectedWalletType == WalletType.onChain
                    ? 'assets/icons/bitcoin_savings.svg'
                    : 'assets/icons/lightning_spending.svg',
              ),
              const SizedBox(width: kSpacingUnit),
              Text(selectedWalletType.label),
              const Spacer(),
              TextButton(
                  child: const Text('Change'),
                  onPressed: () => onWalletTypeChange(
                        selectedWalletType == WalletType.onChain
                            ? WalletType.lightning
                            : WalletType.onChain,
                      )),
            ],
          ),
        ),
        const SizedBox(height: kSpacingUnit),
        // Helper text
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kSpacingUnit * 1.5,
          ),
          child: Text(
            'The wallet to receive the funds in.',
            style: theme.textTheme.bodySmall!.copyWith(
              color: theme.colorScheme.secondary,
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
