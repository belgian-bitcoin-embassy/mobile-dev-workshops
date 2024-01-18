import 'package:flutter/material.dart';

class WalletActionsBottomSheet extends StatelessWidget {
  const WalletActionsBottomSheet({Key? key}) : super(key: key);

  static const List<Tab> actionTabs = <Tab>[
    Tab(
      icon: Icon(Icons.arrow_downward),
      text: 'Receive funds',
    ),
    Tab(
      icon: Icon(Icons.arrow_upward),
      text: 'Send funds',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: actionTabs.length,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: const [
            CloseButton(),
          ],
          bottom: const TabBar(
            tabs: actionTabs,
          ),
        ),
        body: TabBarView(
          children: [
            Container(),
            Container(),
          ],
        ),
      ),
    );
  }
}
