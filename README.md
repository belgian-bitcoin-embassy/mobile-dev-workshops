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

### Install Polar (and Docker Desktop/Server)

Polar is a Bitcoin and Lightning Network development tool that makes it easy to run a local network of Bitcoin and Lightning test nodes and to interact with them or use them in the development of applications.

Download from https://lightningpolar.com/ and follow the installation instructions for your operating system.

Make sure you have [Docker Desktop](https://www.docker.com/products/docker-desktop) installed on Windows or MacOS and [Docker Server](https://docs.docker.com/engine/install/#server) on Linux, since the Polar app needs Docker to run the nodes.

### Install Rust

Alongside our Bitcoin node in Polar, we will need to run an Electrum server to be able to use the Bitcoin Development Kit (BDK) library. The Electrum server we will use is written in Rust, so we will need to install Rust to be able to run it.

You can use rustup to install Rust, following the instructions on https://rustup.rs/.

### clang, cmake and build-essential (Ubuntu only)

If you are using Ubuntu, also run the following to be able to run the Electrum server:

```bash
$ sudo apt update
$ sudo apt install clang cmake build-essential  # for building 'rust-rocksdb'
```

### Have git installed

Since we will be using git to clone the workshop repository to have the same starting point again from time to time, make sure you have git installed on your system. You can follow instructions from [git-scm](https://git-scm.com/downloads) or [github](https://github.com/git-guides/install-git) to install it.

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

In the `HomeScreen` widget, change the complete body for a `ListView`. This will allow us to add different components one above the other and scroll if the screen is not big enough to show all of them.

```dart
// In the Scaffold widget ...
  body: ListView(
    children: [
        // ...
    ],
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
      body: ListView(
        children: const [
          SizedBox(
            height: kSpacingUnit * 24,
            child: WalletCardsList(),
          ),
        ],
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

The `TransactionsList` will be a `ListView` with scrolling disabled and `shrinkWrap` on true, since it will be placed in an already scrollable parent with infite height, the `ListView` of the `HomeScreen`. The `TransactionsList` widget will now look like this:

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
              true, // To set constraints on the ListView in an infinite height parent (ListView in HomeScreen)
          physics:
              const NeverScrollableScrollPhysics(), // Scrolling is handled by the parent (ListView in HomeScreen)
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

#### Wallet actions

Now for the actions like receiving and sending we would want to do with a Bitcoin wallet, we will add a floating button that opens a bottom sheet modal with possible actions. For now, we will only add the options to receive and send bitcoin.

To add a floating button, just add the following to the `Scaffold` widget:

```dart
// HomeScreen Scaffold widget ...
    floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => const WalletActionsBottomSheet(),
        ),
        child: SvgPicture.asset(
          'assets/icons/in_out_arrows.svg',
        ),
    ),
// ...
```

For the wallet actions, we will create a separate features folder `lib/features/wallet_actions` and add the `WalletActionsBottomSheet` widget to it in the `wallet_actions_bottom_sheet.dart` file:

```dart
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
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.all(kSpacingUnit * 4),
          child: TabBarView(
            children: [
              const ReceiveTab(),
              Container(),
            ],
          ),
        ),
      ),
    );
  }
}
```

This widget will show a tab bar with two tabs, one for receiving and one for sending funds. We will now replace the `Container` widgets with the actual widgets for receiving and sending funds.

In the `lib/features/wallet_actions` folder, create a folder for the receive feature, called `receive`, and a folder for the send feature, called `send`. In the `receive` folder, create a file called `receive_tab.dart` and in the `send` folder, create a file called `send_tab.dart`.

In the `receive_tab.dart` file we will create the widget `ReceiveTab`. A Bitcoin address itself doesn't encode any amount or label or description, but most Bitcoin wallets currently support the BIP21 URI scheme, which allows to pass a label, description and amount along with the address. This permits the reading wallet to pre-fill the amount and remember the paying user who and/or what he is paying for again. We will use this scheme to generate a QR code that can be scanned by other wallets to easily send funds. So the `ReceiveTab` widget will have a `TextField` for the amount, a `TextField` for the label and a `TextField` for the description or message.
Aside from those input fields, we will need to be able to show an error message in case the amount is valid or if no wallet is available to generate an address for yet. At last we will need a button to confirm the input and generate the Bitcoin address. Adding these components to the `ReceiveTab` widget will look like this:

```dart
class ReceiveTab extends StatelessWidget {
  const ReceiveTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: kSpacingUnit * 2),
        // Amount Field
        const SizedBox(
          width: 250,
          child: TextField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Amount (optional)',
              hintText: '0',
              helperText: 'The amount you want to receive in BTC.',
            ),
            onChanged: null,
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Label Field
        const SizedBox(
          width: 250,
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Label (optional)',
              hintText: 'Alice',
              helperText: 'A name the payer knows you by.',
            ),
            onChanged: null,
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Message Field
        const SizedBox(
          width: 250,
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Message (optional)',
              hintText: 'Payback for dinner.',
              helperText: 'A note to the payer.',
            ),
            onChanged: null,
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Error message
        const SizedBox(
          height: kSpacingUnit * 2,
          child: Text(
            true
                ? 'You need to create a wallet first.'
                : false
                    ? 'Please enter a valid amount.'
                    : '',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Generate invoice Button
        ElevatedButton.icon(
          onPressed: null,
          label: const Text('Generate invoice'),
          icon: const Icon(Icons.qr_code),
        ),
      ],
    );
  }
}
```

The `SendTab` widget will be very similar, it will have a `TextField` for the amount to send, a `TextField` for the address to send to, a `Slider` to select the fee rate, a `Text` widget to show any errors and a button to send the transaction. Implemented the `SendTab` widget will look like this:

```dart
class SendTab extends StatelessWidget {
  const SendTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: kSpacingUnit * 2),
        // Amount Field
        const SizedBox(
          width: 250,
          child: TextField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Amount',
              hintText: '0',
              helperText: 'The amount you want to send in BTC.',
            ),
            onChanged: null,
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Invoice Field
        const SizedBox(
          width: 250,
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Invoice',
              hintText: '1bc1q2c3...',
              helperText: 'The invoice to pay.',
            ),
            onChanged: null,
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Fee rate slider
        SizedBox(
          width: 250,
          child: Column(
            children: [
              const Slider(
                value: 0.5,
                onChanged: null,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: kSpacingUnit * 2),
                child: Text(
                  'The fee rate (sat/vB) to pay for this transaction.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Error message
        const SizedBox(
          height: kSpacingUnit * 2,
          child: Text(
            false
                ? 'Please enter a valid amount.'
                : true
                    ? 'Not enough funds available.'
                    : false
                        ? 'Please enter a valid invoice.'
                        : '',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Send funds Button
        ElevatedButton.icon(
          onPressed: null,
          label: const Text('Send funds'),
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }
}
```

Now replace the `Container` widgets in the `WalletActionsBottomSheet` widget with the `ReceiveTab` and `SendTab` widgets:

```dart
// WalletActionsBottomSheet widget ...
  TabBarView(
    children: [
      const ReceiveTab(),
      const SendTab(),
    ],
  ),
// ...
```

#### Wrap up

With this, we have the basic layout of our Bitcoin wallet app. It should look something like this now:

![Screenshot 2024-01-14 at 22 27 56](https://github.com/belgian-bitcoin-embassy/mobile-dev-workshops/assets/92805150/53016ef4-fd4e-4738-a002-fc745e413b6d)

![Screenshot 2024-01-18 at 22 36 06](https://github.com/belgian-bitcoin-embassy/mobile-dev-workshops/assets/92805150/5e02bf0b-98d7-4300-b5aa-9353f14275d3)

![Screenshot 2024-01-18 at 22 36 20](https://github.com/belgian-bitcoin-embassy/mobile-dev-workshops/assets/92805150/4c742ee1-63a5-4f2b-97af-1925b4fbed98)

All data is hardcoded for now, but in the next steps we will add the functionality to generate a new wallet and display the balance and transactions.

### 2. Wallet generation

To generate a new wallet, we will use the [Bitcoin Development Kit (BDK)](https://bitcoindevkit.org). It is a library that provides a Rust API with various Bitcoin functionalities, like generating a new wallet, creating addresses, transactions, etc. A Flutter package exists that wraps the Rust API in a Dart API, so that we can use it in our Flutter app. The package is called [bdk_flutter](https://github.com/LtbLightning/bdk-flutter) and we can install it by running `flutter pub add bdk_flutter` from the command line.

#### BDK setup

Make sure the Minimum SDK version in the `android/app/build.gradle` file is at least 23, as the BDK library requires it. For iOS, the minimum version should be 12.0, so make sure the
podfile in the `ios` folder has the following:

```ruby
platform :ios, '12.0'
```

And the `ios/Runner/Info.plist` file has the following:

```xml
<key>MinimumOSVersion</key>
<string>12.0</string>
```

Then run `cd ios && pod install && cd ..` from the command line for the changes to take effect.

#### Generate a new wallet

To start easy, let's just use the bdk package directly in our `AddNewWalletCard` widget to generate a BIP39 seed phrase, also know as recovery phrase or mnemonic, when we press the button and just print it out for now.

In the `AddNewWalletCard` widget change the `onTap` callback of the `InkWell` widget:

```dart
// AddNewWalletCard widget ...
    onTap: () async {
        print('Add a new wallet');
        final mnemonic = await Mnemonic.create(WordCount.Words12);
        print('Mnemonic created: ${mnemonic.asString()}');
    },
// ...
```

If you run the app now and press the add new wallet card, you should see a new seed phrase printed to the console every time you press it.

#### Securely storing the wallet

Now that we can generate a new wallet, we need to store it securely. For this, we will use the [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage) package. It is a package that allows us to store data securely in the device's keychain or keystore. To install it, run `flutter pub add flutter_secure_storage` from the command line.

To separate the logic concerning the storage and retrieval of the mnemonic, we will create a new class called `MnemonicRepository` in the `lib/repositories` folder. This class will have three initial methods, setting or storing a new mnemonic, retrieving the mnemonic and deleting the mnemonic. We create an abstract class with these methods so that we can easily create a mock implementation for testing purposes in the future.

```dart
abstract class MnemonicRepository {
  Future<void> setMnemonic(String mnemonic);
  Future<String?> getMnemonic();
  Future<void> deleteMnemonic();
}
```

Then we create a new class called `SecureStorageMnemonicRepository` that will be a concrete implementation to store the mnemonic in secure storage. The `SecureStorageMnemonicRepository` class will look like this:

```dart
class SecureStorageMnemonicRepository implements MnemonicRepository {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _mnemonicKey = 'mnemonic';

  @override
  Future<void> setMnemonic(String mnemonic) async {
    await _secureStorage.write(key: _mnemonicKey, value: mnemonic);
  }

  @override
  Future<String?> getMnemonic() {
    return _secureStorage.read(key: _mnemonicKey);
  }

  @override
  Future<void> deleteMnemonic() {
    return _secureStorage.delete(key: _mnemonicKey);
  }
}
```

This class can now be used to take care of the storage and retrieval of the mnemonic. Let's bring together the generation and storage in a service class.
Since we might add other types of wallets in the future, like Lightning, we will first define an abstract class `WalletService` and add two simple methods to start, one to add a wallet and one to delete the wallet through the service:

```dart
abstract class WalletService {
  Future<void> addWallet();
  Future<void> deleteWallet();
}
```

For the concrete implementation of our on-chain wallet we will create a new class called `BitcoinWalletService` that will use `bdk_flutter` to generate a new wallet and `SecureStorageMnemonicRepository` to store and delete the mnemonic. The `BitcoinWalletService` will look like this:

```dart
class BitcoinWalletService implements WalletService {
  final MnemonicRepository _mnemonicRepository;

  BitcoinWalletService({required MnemonicRepository mnemonicRepository})
      : _mnemonicRepository = mnemonicRepository;

  @override
  Future<void> addWallet() async {
    final mnemonic = await Mnemonic.create(WordCount.Words12);
    await _mnemonicRepository.setMnemonic(mnemonic.asString());
  }

  @override
  Future<void> deleteWallet() async {
    await _mnemonicRepository.deleteMnemonic();
  }
}
```

#### Bringing together the UI and the service

What is now missing is a way to bring together the UI and the service without mixing up the logic. For this, we could use state management packages like provider, riverpod, etc., but for now we will just manage the state in the `HomeScreen` widget itself and create a controller class that will be responsible of updating it.

To be able to manage state, we first need to define the fields or data that forms part of the state.
As we need to show the wallet balance card in the UI if a wallet was added, we will create a model for this data called `WalletBalance` in the `lib/view_models` folder:

```dart
@immutable
class WalletBalance extends Equatable {
  const WalletBalance({
    required this.walletName,
  });

  final String walletName;

  @override
  List<Object> get props => [
        walletName,
      ];
}
```

Currently it only holds a name for the wallet, since we have not implemented a way to get the balance yet. We will add this in the next steps.
In the future when we add Lightning, it can also hold the type of wallet to know which icon to show, etc.

Now we can use it as a field of the HomeState class that will hold the state of the HomeScreen widget. Just as the WalletBalance, we will annotate it with `@immutable` and extend it with Equatable of the `equatable` package so that Flutter can easily know when the state has changed and rebuild the widget. Since it is part of the home feature only, just put it in the `lib/features/home` folder:

```dart
@immutable
class HomeState extends Equatable {
  const HomeState({
    this.walletBalance,
  });

  final WalletBalance? walletBalance;

  HomeState copyWith({
    WalletBalance? walletBalance,
    bool clearWalletBalance = false,
  }) {
    return HomeState(
      walletBalance:
          clearWalletBalance ? null : walletBalance ?? this.walletBalance,
    );
  }

  @override
  List<Object?> get props => [walletBalance];
}
```

The copyWith method is used to create a new instance of the state with the same values and only update the fields that are passed to it instead of mutating an existing instance. This is important for Flutter to know when the state has changed and rebuild the widget.

Now we can create the controller. In the same folder of the home feature, next to the screen and state, add the `home_controller.dart` file. The controller should be able to get the current state and update it. To do this, we will pass two callbacks to the controller, one to get the current state and one to update the state. This way, the controller does not need to know about the UI and the UI does not need to know about the controller. It should also have a dependency to the `WalletService` to be able to add and delete wallets. The `HomeController` will look like this:

```dart
class HomeController {
  final HomeState Function() _getState;
  final Function(HomeState state) _updateState;
  final WalletService _bitcoinWalletService;

  static const walletName =
      'Savings'; // For a real app, the name should be dynamic and be set by the user when adding the wallet and stored in some local storage.

  HomeController({
    required getState,
    required updateState,
    required bitcoinWalletService,
  })  : _getState = getState,
        _updateState = updateState,
        _bitcoinWalletService = bitcoinWalletService;

  Future<void> addNewWallet() async {
    try {
      await _bitcoinWalletService.addWallet();
      _updateState(
        _getState().copyWith(
          walletBalance: WalletBalance(
            walletName: walletName,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteWallet() async {
    try {
      await _bitcoinWalletService.deleteWallet();
      _updateState(_getState().copyWith(clearWalletBalance: true));
    } catch (e) {
      print(e);
    }
  }
}
```

Now it is time to bring everything together again. The `WalletService`'s will generally be services that are instantiated and initialized only once and be shared/available throughout the whole app.
In productive code, you would probably use a Provider or other dependency injection frameworks to do this, but to keep the code and dependencies as unopiniated as possible for the workshop, we will just instantiate and the `BitcoinWalletService` in the `main` function and pass it down to the `HomeScreen` widget. The `main.dart` file will now look like this:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Add this

  final bitcoinWalletService = BitcoinWalletService(
    mnemonicRepository: SecureStorageMnemonicRepository(),
  ); // Add this

  runApp(MyApp(
    bitcoinWalletService: bitcoinWalletService, // Add this
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.bitcoinWalletService, super.key}); // Add this

  final WalletService bitcoinWalletService; // Add this

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitcoin Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: HomeScreen(
        bitcoinWalletService: bitcoinWalletService, // Add this
      ),
    );
  }
}
```

Now we can add the state and the controller in the `HomeScreen` widget. First, we will add the state to the widget. To do this, we will need to change from a `StatelessWidget` to a `StatefulWidget` widget. This way, we can use the `setState` method to update the state and let Flutter rebuild the widget.
With the state and controller in place, we can now use the state to show the correct widgets in the UI. We will use the `walletBalance` field of the state to show the `WalletBalanceCard` if it is not null and the `AddNewWalletCard` otherwise. For this we need to pass the `walletBalance` to the `WalletCardsList` widget and add callbacks to the `WalletCardsList` and `WalletBalanceCard` widgets to be able to add and delete wallets. Also the `WalletCardsList`, `WalletBalanceCard` and `AddNewWalletCard` widgets will be updated.
The `HomeScreen` widget will now look like this:

```dart
// Changed to a StatefulWidget
class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.bitcoinWalletService, super.key});

  final WalletService bitcoinWalletService;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  HomeState _state = const HomeState(); // Added the state
  late HomeController _controller; // Added the controller

  @override
  void initState() {
    super.initState();

    _controller = HomeController(
      getState: () => _state,
      updateState: (HomeState state) => setState(() => _state = state),
      bitcoinWalletService: widget.bitcoinWalletService,
    );
  } // Set the controller in the initState method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      endDrawer: const Drawer(),
      body: ListView(
        children: [
          SizedBox(
            height: kSpacingUnit * 24,
            child: WalletCardsList(
              _state.walletBalance == null ? [] : [_state.walletBalance!], // Use the state here
              onAddNewWallet: _controller.addNewWallet, // Added callback from the controller
              onDeleteWallet: _controller.deleteWallet, // Added callback from the controller
            ),
          ),
          // ... rest of the HomeScreen widget
```

And the `WalletCardsList`, `WalletBalanceCard` and `AddNewWalletCard` widgets will be updated as follow:

```dart
// in wallet_cards_list.dart
class WalletCardsList extends StatelessWidget {
  const WalletCardsList(
    this.walletBalances, {
    required this.onAddNewWallet,
    required this.onDeleteWallet,
    super.key,
  });

  final List<WalletBalance> walletBalances;
  final VoidCallback onAddNewWallet;
  final VoidCallback onDeleteWallet;

  @override
  Widget build(context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: walletBalances.isEmpty ? 1 : walletBalances.length,
      itemExtent: kSpacingUnit * 20,
      itemBuilder: (BuildContext context, int index) {
        if (walletBalances.isEmpty) {
          return AddNewWalletCard(onPressed: onAddNewWallet);
        } else {
          return WalletBalanceCard(
            walletBalances[index],
            onDelete: onDeleteWallet,
          );
        }
      },
    );
  }
}

// in wallet_balance_card.dart
class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard(this.walletBalance,
      {required this.onDelete, Key? key})
      : super(key: key);

  final WalletBalance walletBalance;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    //  ... rest of components
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(kSpacingUnit),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          walletBalance.walletName // Used the wallet balance model of the state here
                          style: theme.textTheme.labelMedium,
                        ),
                        const SizedBox(height: kSpacingUnit),
                        Text(
                          '0 BTC',
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
                onPressed: onDelete, // Added callback
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

// add_new_wallet_card.dart
class AddNewWalletCard extends StatelessWidget {
  const AddNewWalletCard({required this.onPressed, Key? key}) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(kSpacingUnit),
        onTap: onPressed,
        // ... rest of wdiget
      )
    );
  }
}
```

#### Obtaining the balance

To obtain the balance we will also use the Bitcoin Development Kit, through `bdk_flutter`, but to do this we need to dive a bit deeper in how this package works.

We will need to create a BDK `Wallet` and a `Blockchain` instance. The `Wallet` is to be able to derive addresses and create and sign transactions and the `Blockchain` instance is needed to sync with the Bitcoin blockchain to obtain the needed data, like the utxo's and with that the balance, and to broadcast our own transactions later.

We will add them both as fields of our `BitcoinWalletService`, since this is the class using BDK and responsible for the on-chain Bitcoin wallet.

```dart
class BitcoinWalletService implements WalletService {
  final MnemonicRepository _mnemonicRepository;
  Wallet? _wallet;
  late Blockchain _blockchain;
  // ... rest of class
}
```

We declare the wallet as nullable, since we want to be able to know if a wallet is existing or not as to set the correct Card in the UI.

The `Blockchain` instance is a late field, since its initialization is asynchronous. To initialize both the `Wallet` and the `Blockchain` instance, we will create some helper functions in the `BitcoinWalletService` class. To initialize the `Blockchain` instance we just need to configure a Bitcoin node or source where he can get the Bitcoin blockchain data from. To start we will use a public Electrum server from Blockstream for Testnet. Later we will see how to use a local regtest node to not need testnet coins for testing. We will add the following helper function to the `BitcoinWalletService` class:

```dart
Future<void> _initBlockchain() async {
  _blockchain = await Blockchain.create(
    config: const BlockchainConfig.electrum(
      config: ElectrumConfig(
        retry: 5,
        url: "ssl://electrum.blockstream.info:60002",
        validateDomain: false,
        stopGap: 10,
      ),
    ),
  );
}
```

BDK creates a `Wallet` based on Output Descriptors. Output Descriptors in Bitcoin are a way to describe collections of output scripts, like Pay-to-witness-script-hash scripts (P2WSH) or Pay-to-taproot outputs (P2TR), etc. With the descriptor defined, the derivation path of the wallet is know and it can derive addresses of the desired type.
A different output descriptor for external/receive addresses should be used than for internal/change addresses. This is to be able to differentiate between incoming and outgoing transactions (track or audit what you received without revealing what you've spend) and to be able to derive the correct addresses for change outputs of transactions. For this wallet we will create native segwit addresses based on the BIP84 standard. We add the following helper functions to the `BitcoinWalletService` class:

```dart
Future<void> _initWallet(Mnemonic mnemonic) async {
    final descriptors = await _getBip84TemplateDescriptors(mnemonic);
    _wallet = await Wallet.create(
      descriptor: descriptors.$1,
      changeDescriptor: descriptors.$2,
      network: Network.Testnet,
      databaseConfig: const DatabaseConfig
          .memory(), // Txs and UTXOs related to the wallet will be stored in memory
    );
  }

  Future<(Descriptor receive, Descriptor change)> _getBip84TemplateDescriptors(
    Mnemonic mnemonic,
  ) async {
    const network = Network.Testnet;
    final secretKey =
        await DescriptorSecretKey.create(network: network, mnemonic: mnemonic);
    final receivingDescriptor = await Descriptor.newBip84(
        secretKey: secretKey,
        network: network,
        keychain: KeychainKind.External);
    final changeDescriptor = await Descriptor.newBip84(
        secretKey: secretKey,
        network: network,
        keychain: KeychainKind.Internal);

    return (receivingDescriptor, changeDescriptor);
  }
```

Now in the `addWallet` method of the `BitcoinWalletService` class, we can call these helper functions to initialize the `Wallet` when a new wallet is added:

```dart
@override
Future<void> addWallet() async {
  final mnemonic = await Mnemonic.create(WordCount.Words12);
  await _mnemonicRepository.setMnemonic(mnemonic.asString());
  await _initWallet(mnemonic); // Add this
  print(
      'Wallet added with mnemonic: ${mnemonic.asString()} and initialized!');
}
```

Since BDK is ment to be as flexible and unopiniated as possible to support different types of applications, platforms and resources, syncing the blockchain data for a wallet is not done automatically in the back. The developer using BDK should decide when and how to sync the blockchain data. To do this we add the sync function to the `BitcoinWalletService` class:

```dart
Future<void> sync() async {
  await _wallet!.sync(_blockchain);
}
```

This way we can control when the wallet should sync with the blockchain and not use resources when it is not needed.
To be able to sync a wallet, a `Blockchain` instance should already be available. So let's think about when and how to initialize everything.
To not complicate things, let's just initialize the `Blockchain` instance at start when the `BitcoinWalletService` is instantiated and initialize the `Wallet` when a new wallet is added or when the app is restarted and a wallet is already existing. To do this, we will add a new method to the `BitcoinWalletService` class:

```dart
Future<void> init() async {
  print('Initializing BitcoinWalletService...');
  await _initBlockchain();
  print('Blockchain initialized!');

  final mnemonic = await _mnemonicRepository.getMnemonic();
  if (mnemonic != null && mnemonic.isNotEmpty) {
    await _initWallet(await Mnemonic.fromString(mnemonic));
    await sync();
    print('Wallet with mnemonic $mnemonic found, initialized and synced!');
  } else {
    print('No wallet found!');
  }
}
```

Now just call this method in the main after the `BitcoinWalletService` is instantiated:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bitcoinWalletService = BitcoinWalletService(
    mnemonicRepository: SecureStorageMnemonicRepository(),
  );
  await bitcoinWalletService.init(); // Add this

  runApp(MyApp(
    bitcoinWalletService: bitcoinWalletService,
  ));
}
```

Now our `Blockchain` instance is always created at start and our `Wallet` instance is also created and synced at startup if a wallet was already existing, or when a new wallet is added.
We should make sure the UI also reflects this at startup. To know if a `Wallet` was already existing, we can check if the `Wallet` field of the `BitcoinWalletService` is null or not. If it is null, we show the `AddNewWalletCard` and if it is not null, we show the `WalletBalanceCard`. We will add a getter to the `BitcoinWalletService` and a new method to the `HomeController` to do this:

```dart
// ... In `BitcoinWalletService` class
  bool get hasWallet => _wallet != null;
// ... rest of class
```

```dart
// ... In `HomeController` class
  Future<void> init() async {
    if ((_bitcoinWalletService as BitcoinWalletService).hasWallet) {
      _updateState(
        _getState().copyWith(
          walletBalance: WalletBalance(
            walletName: walletName,
          ),
        ),
      );
    } else {
      _updateState(_getState().copyWith(clearWalletBalance: true));
    }
  }
// ... rest of class
```

And call this method in the `initState` method of the `HomeScreen` widget:

```dart
// ... In `HomeScreenState` class
  @override
  void initState() {
    super.initState();

    _controller = HomeController(
      getState: () => _state,
      updateState: (HomeState state) => setState(() => _state = state),
      bitcoinWalletService: widget.bitcoinWalletService,
    );
    _controller.init(); // Add this
  }
// ... rest of class
```

With all of this in place, we can finally use the `Wallet` instance to obtain the balance. For this we will add a new method to the `BitcoinWalletService` class:

```dart
// ... In `BitcoinWalletService` class
  @override
  Future<int> getSpendableBalanceSat() async {
    final balance = await _wallet!.getBalance();

    return balance.spendable;
  }
// ... rest of class
```

As can be observed, we added an @override annotation to the method. This is because we will add a new abstract method to the `WalletService` interface to be able to obtain spendable balance,since this is something any type of wallet should be able to do. The `WalletService` interface will now look like this:

```dart
abstract class WalletService {
  Future<void> addWallet();
  Future<void> deleteWallet();
  Future<int> getSpendableBalanceSat(); // Added this
}
```

In our `WalletBalance` view model, we will add a new field to hold the balance in satoshis and a getter to obtain the balance in BTC. The `WalletBalance` class will now look like this:

```dart
@immutable
class WalletBalance extends Equatable {
  const WalletBalance({
    required this.walletName,
    required this.balanceSat,
  });

  //final WalletType walletType;
  final String walletName;
  final int balanceSat;

  double get balanceBtc => balanceSat / 100000000;

  @override
  List<Object> get props => [
        walletName,
        balanceSat,
      ];
}
```

Now we have to update the `HomeController` to set the balance in the states it updates. Add the following to the `WalletBalance` instances in the `HomeController`:

```dart
balanceSat: await _bitcoinWalletService.getSpendableBalanceSat(),
```

Now in the `WalletBalanceCard` where the balance should be really shown in the UI, we can just get it from the `walletBalance` field like this:

```dart
// ... In `WalletBalanceCard` class
  Expanded(
    child: Padding(
      padding: const EdgeInsets.all(kSpacingUnit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            walletBalance.walletName,
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: kSpacingUnit),
          Text(
            '${walletBalance.balanceBtc} BTC', // Changed here
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    ),
  )
// ... rest of class
```

Try it out and you should see a balance of 0.0 BTC for an added wallet in the UI.

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

```

```

```

```

```

```
