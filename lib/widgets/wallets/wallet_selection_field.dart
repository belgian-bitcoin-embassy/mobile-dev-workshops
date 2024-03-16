import 'package:mobile_dev_workshops/constants.dart';
import 'package:mobile_dev_workshops/enums/wallet_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WalletSelectionField extends StatelessWidget {
  const WalletSelectionField({
    super.key,
    this.selectedWallet,
    required this.availableWallets,
    required this.onWalletTypeChange,
  });

  final WalletType? selectedWallet;
  final List<WalletType> availableWallets;
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
                selectedWallet == WalletType.onChain
                    ? 'assets/icons/bitcoin_savings.svg'
                    : 'assets/icons/lightning_spending.svg',
              ),
              const SizedBox(width: kSpacingUnit),
              Text(selectedWallet!.label),
              const Spacer(),
              TextButton(
                onPressed: availableWallets.length > 1
                    ? () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Select Wallet'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: availableWallets
                                    .map(
                                      (wallet) => ListTile(
                                        title: Text(wallet.label),
                                        onTap: () {
                                          onWalletTypeChange(wallet);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            );
                          },
                        );
                      }
                    : null,
                child: const Text('Change'),
              ),
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
