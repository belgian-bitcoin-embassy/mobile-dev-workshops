import 'package:flutter/material.dart';
import 'package:bdk_flutter/bdk_flutter.dart';

class AddNewWalletCard extends StatelessWidget {
  const AddNewWalletCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          print('Add a new wallet');
          final mnemonic = await Mnemonic.create(WordCount.Words12);
          print('Seed phrase generated: ${mnemonic.asString()}');
        },
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
            ),
            Text('Add a new wallet'),
          ],
        ),
      ),
    );
  }
}
