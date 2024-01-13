import 'package:flutter/material.dart';

class AddNewWalletCard extends StatelessWidget {
  const AddNewWalletCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // Todo: Navigate to add a new wallet
          print('Add a new wallet');
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
