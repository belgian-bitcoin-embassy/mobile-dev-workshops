# Bitcoin and Lightning Mobile Development Workshops

This repository contains materials for Bitcoin and Lightning mobile development workshops.
These workshops are intended for developers or anyone willing to learn how to build Bitcoin and Lightning applications for mobile devices.

## Agenda

During the first workshops, the basic functionalities of Bitcoin and Lightning wallets will be implemented.
After that, more advanced topics can be covered based on the interest and/or contribution of the participants.

The exact dates and locations of the workshops will be announced later.

## Prior knowledge

Anyone can assist, but experience in software development is highly recommended, as explaining basics of programming will take us too far from the main topic.

Experience with mobile development or Bitcoin and Lightning is NOT required.
We think the workshops can be fun and of value to both developers that want to learn about Bitcoin and the Lightning Network, as well as Bitcoin and Lightning developers that want to learn about mobile development.

## ⚠️ To do before the workshop

As the workshop will be hands-on, it is required to install some software before attending the workshop and make sure it is working correctly.

Due to time constraints, we will not be able to help with installation issues during the workshop. If you have any problems, please reach out to us beforehand.

### Install an IDE

The instructor of the workshops will be using [Visual Studio Code](https://code.visualstudio.com/), so it might be easier to follow along if you use it too, but any IDE that supports Flutter development will work.

If you install Visual Studio Code, make sure to also install the [Flutter extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter).

### Install Flutter

The mobile development framework used will be Flutter, as to easily build applications for both Android and iOS and to make use of existing Bitcoin and Lightning libraries.

Following the [official installation instructions](https://flutter.dev/docs/get-started/install), install Flutter for your operating system.
The app will be developed to run on both Android and iOS, so if you would like to run the app on both Android and iOS, you will need to install Flutter for both app types. To just run the app during the workshop, it is sufficient to follow the instructions for just one of the two.

Make sure that running `flutter doctor` in a terminal shows no errors, as described in the installation instructions.

### Install Polar

Polar is a Bitcoin and Lightning Network development tool that makes it easy to run a local network of Bitcoin and Lightning test nodes and to interact with them or use them in the development of applications.

Download from https://lightningpolar.com/ and follow the installation instructions for your operating system.

## Workshop 1: Project setup and Bitcoin on-chain wallet

In this workshop, we will set up a Flutter project and implement the basic functionalities of a Bitcoin on-chain wallet, like:

- Generating a new wallet
- Displaying the balance
- Receiving a transaction
- Sending a transaction
- Displaying the transaction history

And if time permits:

- Backing up the wallet
- Importing an existing wallet

We will use the [Bitcoin Development Kit (BDK)](https://bitcoindevkit.org) to implement this functionality.

### 0. App setup

#### App creation

Start by creating a new Flutter project using the `flutter create` command. You can choose any name for the project, but for the sake of this workshop, we will use `bitcoin_flutter_app`, so run `flutter create bitcoin_flutter_app` where you want to create the project.

From the created project folder, you should now be able to run the app on a connected device or emulator using `flutter run`.
If an app with a counter button is shown, everything is working correctly.

We will only be building for Android and iOS during this workshop, so you can remove the other platforms' folders from the project, manually or by running the command `rm -rf linux macos web windows`.

#### `main.dart` file

The `main.dart` file is the entry point of the app and is where we will start. It is located in the `lib` folder of the project.
As you see, there is already some code in there for the counter app that was created by default. We will remove the MyHomePage widget as we will create our own widget for the home screen of the app.

In the MyApp widget, we will change the title to "Bitcoin Flutter App", you can change the color to our beloved Orange color and the home to our own widget that we will create in the next step and will call HomeScreen.

#### Home feature

We will create a folder for all features of the app, called `features`. We can consider having a Home to be a feature and thus create a folder for it in the features folder, called `home`, and a file `home_screen.dart` inside it for the view of our home page. For now, we just create a simple view saying 'Home Screen' in the center of the screen.

```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Home Screen'),
      ),
    );
  }
}
```

In the next steps we will add the initial layout and components for our Bitcoin wallet to the Home Screen.

### 1. Home layout

Our Bitcoin wallet will have a simple, but scalable, layout with an app bar, an horizontal list of balances to add Lightning or other balances in the future, a list of transactions and a floating button to send and receive Bitcoin.

#### App bar

The app bar will just have a menu drawer icon on the right that in the future can be used to open a drawer with some options, like settings, seed backup, etc.

Just add it with the following two lines in the Scaffold widget of the HomeScreen:

```dart
// In the Scaffold widget ...
    appBar: AppBar(),
    endDrawer: const Drawer(),
// ...
```

#### Wallet balances

We will use a horizontal list of balances of the wallets created in the app, so that we can easily add more wallets in the future, like Lightning, etc. For now, we will only have an on-chain Bitcoin wallet, but we will add a Lightning balance in the next workshop.

In the `HomeScreen` widget, change the complete body for a `SingeChildScrollView` with a `Column` inside it. This will allow us to add different components one above the other and scroll if the screen is not big enough to show all of them.

```dart
// In the Scaffold widget ...
    body: SingleChildScrollView(
      child: Column(
        children: [
          // ...
        ],
      ),
    ),
```

The first component we will add is the list of balances. We will create a new widget for it, called `WalletCardsList`, and add it to the `Column` widget. The list will be a horizontal list, so it can grow unlimitedly and be scrolled horizontally if more wallets are added in the future.
To constrain it vertically, we will wrap it in a `SizedBox` widget with a fixed height.
The homescreen now looks like this:

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      endDrawer: const Drawer(),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: kSpacingUnit * 24,
              child: WalletCardsList(),
            ),
          ],
        ),
      ),
    );
  }
}
```

Before we create the `WalletCardsList` itself, let's create the items that will be displayed in the list. We will create a new folder for widgets to separate them from the screens, as they could possibly be reused in other screens in the future. Inside the `lib` folder, create a new folder called `widgets` and inside it a new folder called `wallets` and three files inside it: `add_new_wallet_card.dart`, `wallet_balance_card.dart` and `wallet_cards_list.dart`.

The `add_new_wallet_card.dart` file will contain a widget that will be displayed in the list to add a new wallet. For now, it will just be a card with a plus icon and a label in the center. We will use the `InkWell` widget to make it tappable:

```dart
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
```

The `wallet_balance_card.dart` file will contain a widget that will be displayed in the list for each wallet. For now, it will just be a card with an icon indicating the type of wallet, a label and the balance underneath. It will also have a closing button in the upper corner to easily delete the wallet just for testing now. To be able to show the icon, we will use the `SvgPicture` widget from the `flutter_svg` package, so make sure to do `flutter pub add flutter_svg` from the command line. The specific icons will be placed in a folder in the root of the project, called `assets`, and added to the `pubspec.yaml` file to be able to use them in the app. The `wallet_balance_card.dart` widget will now look like this:

```dart
import 'package:bitcoin_flutter_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({Key? key}) : super(key: key);

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
        onTap: () {
          // Todo: Navigate to wallet
          print('Go to wallet');
        },
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
                    'assets/icons/bitcoin_savings.svg',
                    fit: BoxFit.none, // Don't scale the SVG, keep it at its original size
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
                          'Savings wallet',
                          style: theme.textTheme.labelMedium,
                        ),
                        const SizedBox(height: kSpacingUnit),
                        Text(
                          '0.00000000 BTC',
                          style: theme.textTheme.bodyMedium,
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
                onPressed: () {
                  print('Delete wallet');
                },
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
```

Now we can create the list itself in the `wallet_cards_list.dart` file. Just create a `ListView` with a `ScrollPhysics` to make it scrollable horizontally and add the two widgets we just created to it. The `WalletCardsList` widget will now look like this:

```dart
class WalletCardsList extends StatelessWidget {
  const WalletCardsList({
    super.key,
  });

  final count = 2;

  @override
  Widget build(context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: count,
      itemExtent: kSpacingUnit * 20,
      itemBuilder: (BuildContext context, int index) {
        if (index == count - 1) {
          return const AddNewWalletCard();
        } else {
          return const WalletBalanceCard();
        }
      },
    );
  }
}
```

You can play with the count variable to see how the list grows horizontally and the last item is always the add new wallet card.

#### Transaction history

To show the transaction history, we will create a new widget called `TransactionsList` that vertically lists `TransactionListItems` for every transaction that was done with the wallet. Place both in a new folder `lib/widgets/transactions`. The `TransactionListItem` will just be a List tile with a leading icon to show the direction of the transaction, a description and the time of the transaction and an amount:

```dart
class TransactionListItem extends StatelessWidget {
  const TransactionListItem({Key? key}) : super(key: key);

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
```

The `TransactionsList` will be a `ListView` with scrolling disabled and `shrinkWrap` on true, since it should be placed in the Column of an already scrollable parent with infite height, the `SingleChildScrollView` of the `HomeScreen`. The `TransactionsList` widget will now look like this:

```dart
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
```

#### Floating button

Now for the actions like receiving and sending we would want to do with a Bitcoin wallet, we will add a floating button that opens a bottom sheet modal with possible actions. For now, we will only add the options to receive and send bitcoin.

To add a floating button, just add the following to the `Scaffold` widget:

```dart
// HomeScreen Scaffold widget ...
    floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (context) => const WalletActionsBottomSheet(),
        ),
        child: SvgPicture.asset(
          'assets/icons/in_out_arrows.svg',
        ),
    ),
// ...
```

And add the `WalletActionsBottomSheet` widget to the `lib/widgets/wallets` folder:

```dart
class WalletActionsBottomSheet extends StatelessWidget {
  const WalletActionsBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: kSpacingUnit * 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.arrow_downward),
                  text: 'Receive funds',
                ),
                Tab(
                  icon: Icon(Icons.arrow_upward),
                  text: 'Send funds',
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Container(),
                  Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

This widget will show a tab bar with two tabs, one for receiving and one for sending funds. For now, we will just show two empty containers, but in the next steps we will add the functionality to send and receive funds.

#### Wrap up

With this, we have the basic layout of our Bitcoin wallet app. It should look something like this now:

![Screenshot 2024-01-14 at 22 27 56](https://github.com/belgian-bitcoin-embassy/mobile-dev-workshops/assets/92805150/53016ef4-fd4e-4738-a002-fc745e413b6d)

![Screenshot 2024-01-14 at 22 28 10](https://github.com/belgian-bitcoin-embassy/mobile-dev-workshops/assets/92805150/a6c9242a-af0f-489d-a911-ce4b3bbfd7d5)

All data is hardcoded for now, but in the next steps we will add the functionality to generate a new wallet and display the balance and transactions.

### 2. Wallet generation

## Workshop 2: Lightning Network wallet

In this workshop, we will add Lightning node functionality to the app like:

- Displaying the Lightning balance
- Toggle between values in BTC and in Satoshis
- Funding and opening a Lightning channel
- Generating a Lightning invoice
- Paying different types of payment requests (BOLT11, LNURL, Lightning Address, node public key, etc.)
- Displaying the transaction history
- Displaying the channel list
- Closing a Lightning channel

And if time permits:

- Backing up the channels

The [Lightning Development Kit (LDK)](https://lightningdevkit.org) will be used for this.

## Workshop 3: Other Lightning libraries and Lightning Service Provider integration

In this workshop, some other ways to embed a Lightning wallet, like [Breez SDK](https://sdk-doc.breez.technology/), will be shown and we will improve the UX (User eXperience) of the app by integrating with [Lightning Service Providers (LSP's)](https://github.com/BitcoinAndLightningLayerSpecs/lsp).

```

```
