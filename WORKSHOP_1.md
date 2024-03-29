## Workshop 1: Project setup and Bitcoin on-chain wallet

In this workshop, we will set up a Flutter project and implement the basic functionalities of a Bitcoin on-chain wallet, like:

- Generating a new wallet
- Displaying the balance
- Receiving a transaction
- Testing locally with Polar
- Displaying the transaction history
- Sending a transaction

And if time permits:

- Backing up the wallet
- Importing an existing wallet

We will use the [Bitcoin Development Kit (BDK)](https://bitcoindevkit.org) to implement this functionality.

### 0. App setup

#### App creation

Start by creating a new Flutter project using the `flutter create` command. You can choose any name for the project, but for the sake of this workshop, we will use `mobile_dev_workshops`, so run `flutter create mobile_dev_workshops` where you want to create the project.

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
import 'package:mobile_dev_workshops/constants.dart';
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

To show the transaction history, we will create a new widget called `TransactionsList` that vertically lists `TransactionsListItems` for every transaction that was done with the wallet. Place both in a new folder `lib/widgets/transactions`. The `TransactionsListItem` will just be a List tile with a leading icon to show the direction of the transaction, a description and the time of the transaction and an amount:

```dart
class TransactionsListItem extends StatelessWidget {
  const TransactionsListItem({Key? key}) : super(key: key);

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
            return const TransactionsListItem();
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

### 3. Receiving funds

To be able to receive funds, we need to be able to generate Bitcoin addresses. For this we will add a new method to the `BitcoinWalletService` class. Since any type of wallet needs a way to receive funds and generate addresses, we will add a new abstract method to the `WalletService` interface. Lightning wallets use BOLT11 invoices instead of Bitcoin addresses, and Bitcoin addresses were also called invoices in the past, so we will call the method `generateInvoice`:

```dart
abstract class WalletService {
  Future<void> addWallet();
  Future<void> deleteWallet();
  Future<int> getSpendableBalanceSat();
  Future<String> generateInvoice(); // Added this
}
```

In the `BitcoinWalletService` class, we will add a concrete implementation for this method, again using the BDK `Wallet` instance we already have available at this time:

```dart
// ... in BitcoinWalletService class
@override
Future<String> generateInvoice() async {
  final invoice = await _wallet!.getAddress(
    addressIndex: const AddressIndex(),
  );

  return invoice.address;
}
// ... rest of class
```

By using a new `AddressIndex` instance, the descriptor index is incremented so that we can generate a new address every time we call this method. This is important for privacy reasons, since we don't want to reuse addresses.

Now from our `ReceiveTab` we would like to call this `generateInvoice` method when the button is pressed. Let's apply the same pattern as with the `HomeScreen` and add a `receive_controller.dart` and a `receive_state.dart` file in the `lib/features/receive` folder.

The `ReceiveState` class will be used to hold the input field values, possible error and loading flags, and the generated invoice . It should look like this:

```dart
@immutable
class ReceiveState extends Equatable {
  const ReceiveState({
    this.amountSat,
    this.isInvalidAmount = false,
    this.label,
    this.message,
    this.bitcoinInvoice,
    this.isGeneratingInvoice = false,
  });

  final int? amountSat;
  final bool isInvalidAmount;
  final String? label;
  final String? message;
  final String? bitcoinInvoice;
  final bool isGeneratingInvoice;

  double? get amountBtc {
    if (amountSat == null) {
      return null;
    }

    return amountSat! / 100000000;
  }

  String? get bip21Uri {
    if (bitcoinInvoice == null) {
      return null;
    }

    if (amountSat == null && label == null && message == null) {
      return bitcoinInvoice;
    }

    return 'bitcoin:$bitcoinInvoice?'
        '${amountBtc != null ? 'amount=$amountBtc' : ''}'
        '${label != null ? '&label=$label' : ''}'
        '${message != null ? '&message=$message' : ''}';
  }

  ReceiveState copyWith({
    int? amountSat,
    bool? isInvalidAmount,
    String? label,
    String? message,
    String? bitcoinInvoice,
    bool? isGeneratingInvoice,
  }) {
    return ReceiveState(
      amountSat: amountSat ?? this.amountSat,
      isInvalidAmount: isInvalidAmount ?? this.isInvalidAmount,
      label: label ?? this.label,
      message: message ?? this.message,
      bitcoinInvoice: bitcoinInvoice ?? this.bitcoinInvoice,
      isGeneratingInvoice: isGeneratingInvoice ?? this.isGeneratingInvoice,
    );
  }

  @override
  List<Object?> get props => [
        amountSat,
        isInvalidAmount,
        label,
        message,
        bitcoinInvoice,
        isGeneratingInvoice,
      ];
}
```

As you can see, the `bip21Uri` and the `amountBtc` can be derived from the other fields, so getters are used for them instead of adding them as extra fields, saving us the need to set and update them separately.

The `ReceiveController` class will be used to handle and validate the input field changes and update the state accordingly. Also the button press to generate the invoice should be handled here and the `generateInvoice` method of the `BitcoinWalletService` should be called, so it should be possible to pass the `BitcoinWalletService` as a dependency. It should look like this:

```dart
class ReceiveController {
  final ReceiveState Function() _getState;
  final Function(ReceiveState state) _updateState;
  final WalletService _bitcoinWalletService;

  ReceiveController({
    required getState,
    required updateState,
    required bitcoinWalletService,
  })  : _getState = getState,
        _updateState = updateState,
        _bitcoinWalletService = bitcoinWalletService;

  void amountChangeHandler(String? amount) async {
    try {
      if (amount == null || amount.isEmpty) {
        _updateState(
            _getState().copyWith(amountSat: 0, isInvalidAmount: false));
      } else {
        final amountBtc = double.parse(amount);
        final int amountSat = (amountBtc * 100000000).round();
        _updateState(
            _getState().copyWith(amountSat: amountSat, isInvalidAmount: false));
      }
    } catch (e) {
      print(e);
      _updateState(_getState().copyWith(isInvalidAmount: true));
    }
  }

  void labelChangeHandler(String? label) async {
    if (label == null || label.isEmpty) {
      _updateState(_getState().copyWith(label: ''));
    } else {
      _updateState(_getState().copyWith(label: label));
    }
  }

  void messageChangeHandler(String? message) async {
    if (message == null || message.isEmpty) {
      _updateState(_getState().copyWith(message: ''));
    } else {
      _updateState(_getState().copyWith(message: message));
    }
  }

  Future<void> generateInvoice() async {
    try {
      _updateState(_getState().copyWith(isGeneratingInvoice: true));

      final invoice = await _bitcoinWalletService.generateInvoice();
      _updateState(_getState().copyWith(bitcoinInvoice: invoice));
    } catch (e) {
      print(e);
    } finally {
      _updateState(_getState().copyWith(isGeneratingInvoice: false));
    }
  }

  void editInvoice() {
    _updateState(const ReceiveState());
  }
}
```

Now let's connect the logic with the UI again. To add the state and controller to the `ReceiveTab` widget, we will need to change it from a `StatelessWidget` to a `StatefulWidget` widget and initialize the state and the controller just like we did in the `HomeScreen` widget.

```dart
// ... in `ReceiveTab` class
class ReceiveTab extends StatefulWidget {
  const ReceiveTab({required this.bitcoinWalletService, super.key});

  final WalletService bitcoinWalletService;

  @override
  ReceiveTabState createState() => ReceiveTabState();
}

class ReceiveTabState extends State<ReceiveTab> {
  ReceiveState _state = const ReceiveState();
  late ReceiveController _controller;

  @override
  void initState() {
    super.initState();

    _controller = ReceiveController(
      getState: () => _state,
      updateState: (ReceiveState state) => setState(() => _state = state),
      bitcoinWalletService: widget.bitcoinWalletService,
    );
  }

  @override
  Widget build(BuildContext context) {
// ... rest of widget
```

Now for the `build` method we can also take the `isGeneratingInvoice` flag into account to show a loading indicator while the invoice is being generated and we can also check the availability of the `bitcoinInvoice` or `bip21Uri` to show a QR code and a text field to scan and copy the invoice. To do this, let's extract the input fields into a new widget called `ReceiveTabInputFields` and create a new widget called `ReceiveTabInvoice` to show the QR code and the text field. Using the state and controller, the `build` method of the `ReceiveTab` widget will now look like this:

```dart
@override
Widget build(BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      _state.isGeneratingInvoice
          ? const CircularProgressIndicator()
          : _state.bip21Uri == null || _state.bip21Uri!.isEmpty
              ? ReceiveTabInputFields(
                  canGenerateInvoice:
                      (widget.bitcoinWalletService as BitcoinWalletService)
                          .hasWallet,
                  amountChangeHandler: _controller.amountChangeHandler,
                  labelChangeHandler: _controller.labelChangeHandler,
                  messageChangeHandler: _controller.messageChangeHandler,
                  isInvalidAmount: _state.isInvalidAmount,
                  generateInvoiceHandler: _controller.generateInvoice,
                )
              : ReceiveTabInvoice(
                  bip21Uri: _state.bip21Uri!,
                  editInvoiceHandler: _controller.editInvoice,
                ),
    ],
  );
}
```

The `ReceiveTabInputFields` widget will look like this:

```dart
class ReceiveTabInputFields extends StatelessWidget {
  const ReceiveTabInputFields({
    Key? key,
    required this.canGenerateInvoice,
    required this.amountChangeHandler,
    required this.labelChangeHandler,
    required this.messageChangeHandler,
    required this.isInvalidAmount,
    required this.generateInvoiceHandler,
  }) : super(key: key);

  final bool canGenerateInvoice;
  final Function(String?) amountChangeHandler;
  final Function(String?) labelChangeHandler;
  final Function(String?) messageChangeHandler;
  final bool isInvalidAmount;
  final Future<void> Function() generateInvoiceHandler;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: kSpacingUnit * 2),
        // Amount Field
        SizedBox(
          width: 250,
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Amount (optional)',
              hintText: '0',
              helperText: 'The amount you want to receive in BTC.',
            ),
            onChanged: amountChangeHandler,
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),

        // Label Field
        SizedBox(
          width: 250,
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Label (optional)',
              hintText: 'Alice',
              helperText: 'A name the payer knows you by.',
            ),
            onChanged: labelChangeHandler,
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),

        // Message Field
        SizedBox(
          width: 250,
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Message (optional)',
              hintText: 'Payback for dinner.',
              helperText: 'A note to the payer.',
            ),
            onChanged: messageChangeHandler,
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),

        // Error message
        SizedBox(
          height: kSpacingUnit * 2,
          child: Text(
            !canGenerateInvoice
                ? 'You need to create a wallet first.'
                : isInvalidAmount
                    ? 'Please enter a valid amount.'
                    : '',
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Generate invoice Button
        ElevatedButton.icon(
          onPressed: !canGenerateInvoice || isInvalidAmount
              ? null
              : () async {
                  await generateInvoiceHandler();
                },
          label: const Text('Generate invoice'),
          icon: const Icon(Icons.qr_code),
        ),
      ],
    );
  }
}
```

Let's create the `ReceiveTabInvoice` widget that will be shown only when an invoice is generated. To show a QR code, we use the package `qr_flutter`, run `flutter pub add qr_flutter` to add it to the project. Under the QR and the `bip21Uri` as text, we add two buttons, one to go back to edit the input fields of the invoice again and one to copy the `bip21Uri` to the clipboard. The `ReceiveTabInvoice` widget will look like this:

```dart
class ReceiveTabInvoice extends StatelessWidget {
  const ReceiveTabInvoice({
    super.key,
    required this.bip21Uri,
    required this.editInvoiceHandler,
  });

  final String bip21Uri;
  final Function() editInvoiceHandler;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // QR Code
        QrImageView(
          data: bip21Uri,
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Invoice
        Text(bip21Uri),
        const SizedBox(height: kSpacingUnit * 2),
        // Button Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Edit Button
            ElevatedButton.icon(
              onPressed: editInvoiceHandler,
              label: const Text('Edit'),
              icon: const Icon(Icons.edit),
            ),
            // Copy Button
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: bip21Uri)).then(
                  (_) {
                    // Optionally, show a confirmation message to the user.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invoice copied to clipboard!'),
                      ),
                    );
                  },
                );
              },
              label: const Text('Copy'),
              icon: const Icon(Icons.copy),
            ),
          ],
        ),
      ],
    );
  }
}
```

As you will notice, the edit button is more of a clearing of the invoice than really being able to edit the existing values, since we are updating the state with an empty `ReceiveState` instance. To be able to keep the input fields values when the user goes back to edit the invoice, we will need to use the `TextEditingController` class to control the text in the input fields, and in the edit button handler, we should only clear the `bitcoinInvoice` field of the state. But this is something we will not do in the workshop, since it is not the main focus of the workshop and it is not that important for the UX. You can do it yourself as an exercise if you want.

The only thing left now is passing down the `WalletService` to the `ReceiveTab` widget. First to the `WalletActionsBottomSheet` in the `HomeScreen` and then to the `ReceiveTab` widget in the `WalletActionsBottomSheet`:

```dart
// ... in the `HomeScreen` widget
floatingActionButton: FloatingActionButton(
  onPressed: () => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => WalletActionsBottomSheet(
      bitcoinWalletService: widget.bitcoinWalletService, // Add this
    ),
  ),
  child: SvgPicture.asset(
    'assets/icons/in_out_arrows.svg',
  ),
),
// ... rest of widget
```

In the `WalletActionsBottomSheet`:

```dart
class WalletActionsBottomSheet extends StatelessWidget {
  const WalletActionsBottomSheet({
    required WalletService bitcoinWalletService, // Add this
    Key? key,
  })  : _bitcoinWalletService = bitcoinWalletService, // Add this
        super(key: key);

  final WalletService _bitcoinWalletService; // Add this

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
              ReceiveTab(
                bitcoinWalletService: _bitcoinWalletService, // Add this
              ),
              const SendTab(),
            ],
          ),
        ),
      ),
    );
  }
}
```

If everything went well, you should be able to generate Bitcoin **Testnet** invoices and see the QR code and the text field with the invoice, like this when not passing any bip21 parameters:

![Screenshot 2024-01-19 at 00 08 32](https://github.com/belgian-bitcoin-embassy/mobile-dev-workshops/assets/92805150/b5b52154-2067-4e59-809b-03fe7a6b640e)

And like this when passing some bip21 parameters:

![Screenshot 2024-01-19 at 00 09 46](https://github.com/belgian-bitcoin-embassy/mobile-dev-workshops/assets/92805150/a44e0dd0-225d-4907-bc71-eb66fff67d37)

### 4. Testing locally

Now that we can receive funds to our wallet, we should see the balance change when we send funds to the generated invoice.
We could do this on Testnet as we have configured as the network in our wallet, but this would require us to get some Testnet coins first, which are not always easy to get and not unlimited to do as many tests as we want. Testing with real Bitcoin on Mainnet is also not a good idea, since we could lose our funds if we make a mistake and since we would be spending real money on fees innecesarily. Therefore, we will use a local Bitcoin node running in regtest mode to test our wallet. This way we can generate as many coins as we want and we can also control the block generation to be able to mine blocks on demand and see the transactions confirmed in the blockchain. We will use two tools for this, the first one is [Polar](https://lightningpolar.com) to spin up a local Bitcoin node in Regtest mode, and the second one is [Esplora](https://github.com/mempool/electrs), a blockchain index engine to be able to query the blockchain data from our local node.

#### Setting up a Bitcoin Regtest node with Polar

If you haven't done so yet, download and install Polar from the official [website](https://lightningpolar.com/) or [github]
(https://github.com/jamaljsr/polar) following the instructions for your operating system.

This includes installing [Docker Desktop](https://www.docker.com/products/docker-desktop) for MacOS and Windows or [Docker Server](https://docs.docker.com/engine/install/#server) for Linux users, since Polar spins up de local regtest node in a Docker container.

Once installed, open Polar and click on the `Create a Lightning Network` button.
Since we are not integrating a Lightning node in our app yet, we will not use the Lightning node functionality of Polar now, so set all Lightning nodes (LND, Core Lightning and Eclair) to 0, and just leave the Bitcoin Core node at 1 before clicking on `Create Network`:

![Screenshot 2024-01-19 at 14 51 02](https://github.com/belgian-bitcoin-embassy/mobile-dev-workshops/assets/92805150/17451970-bad9-4b36-945a-ad190e61fe3c)

Now click the `Start` button and wait till the network is `Started` up. This should look something like this:

![Screenshot 2024-01-19 at 14 55 07](https://github.com/belgian-bitcoin-embassy/mobile-dev-workshops/assets/92805150/6d1e6f85-710d-44f6-ae0f-0cc4d355efc6)

We now have a local Bitcoin node running in regtest mode.

#### Setting up Esplora Server

To be able to connect to the Bitcoin node from the BDK library, an Electrum Server needs to run alongside the node, since the Polar node itself only exposes the Bitcoin Core RPC interface and not an Electrum RPC interface. To do this, we will use the Esplora Server implementation of mempool, named [electrs](https://github.com/mempool/electrs).

To set it up, just clone the repo in a location of your preference with the following command, enter in the cloned folder and checkout the `mempool` branch:

```bash
git clone https://github.com/mempool/electrs && cd electrs
git checkout mempool
```

Assuming the Rust toolchain is installed as required in the prerequisites, we can now run the server with the following command specifying the path to the `.bitcoin` directory of your Bitcoin Core node in Polar and specify the network, which is regtest:

```bash
cargo run --release --bin electrs -- -vvvv --daemon-dir ~/.polar/networks/1/volumes/bitcoind/backend1/ --network=regtest
```

If you already created more networks in Polar, the 1 in the path of the `--daemon-dir`` parameter might be different. To find the correct path, check out the Mounts in Docker for the Bitcoin Core (bitcoind) container. It should be the one mounted to the internal /home/bitcoin/.bitcoin path.

If it is the first time you run it, first some dependencies will be downloaded and installed, but then the server should start and you should see something like this:

```log
DEBUG - Server listening on 127.0.0.1:24224
DEBUG - Running accept thread
...
INFO - Electrum RPC server running on 127.0.0.1:60401
INFO - REST server running on 127.0.0.1:3002
```

The HTTP REST server is what we need to connect to from the app. Check the port it is running on, in most cases it will be on port 3002, since it is the default port.
We use this port to connect to the server from our app. In the `BitcoinWalletService` we will change the configurations of the `Blockchain` instance and change the network to `Network.Regtest` wherever we used `Network.Testnet` before.

In production code, it would be better to extract these node configurations to a separate file and load them from there, so that we can easily switch between networks and nodes without having to change the code. But for now, we will just hardcode them in the `BitcoinWalletService` class. The `Blockchain` instance should now be initialized like this:

```dart
Future<void> _initBlockchain() async {
  _blockchain = await Blockchain.create(
    config: const BlockchainConfig.esplora(
      config: EsploraConfig(
        baseUrl: "http://10.0.2.2:3002",
        stopGap: 10,
      ),
    ),
  );
}
```

And the `Wallet` instance and its descriptors should now be initialized with the `Network.Regtest` network:

```dart
Future<void> _initWallet(Mnemonic mnemonic) async {
    final descriptors = await _getBip84TemplateDescriptors(mnemonic);
    _wallet = await Wallet.create(
      descriptor: descriptors.$1,
      changeDescriptor: descriptors.$2,
      network: Network.Regtest, // Changed here
      databaseConfig: const DatabaseConfig
          .memory(),
    );
  }

  Future<(Descriptor receive, Descriptor change)> _getBip84TemplateDescriptors(
    Mnemonic mnemonic,
  ) async {
    const network = Network.Regtest; // Changed here
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

Now run the app, add a wallet if you don't have one yet and generate an invoice (receive address).

Then go to the Polar app and in the `Actions` tab of the Bitcoin node, click on the `mine` button to mine some blocks and get some coins. Make sure you mine at least 100 blocks to have some coins that are mature and can be spent. Then click on the button underneath saying `Send coins`:

![Screenshot 2024-01-20 at 22 33 15](https://github.com/belgian-bitcoin-embassy/mobile-dev-workshops/assets/92805150/621f7a86-c35a-460f-8133-fa3bc058eb32)

Now you can paste the Bitcoin invoice/address you generated in the app to send some coins to it. Make sure you have the box with `Automatically mine 6 blocks to confirm the transaction` checked and click on the `Send` button:

![Screenshot 2024-01-20 at 23 51 51](https://github.com/belgian-bitcoin-embassy/mobile-dev-workshops/assets/92805150/c899eb6a-fd06-456a-8ac6-c947580e1830).

We haven't implemented any streams to listen to incoming transactions yet, neither do we have a way to refresh the balance yet, we will implement the refresh action in the next step. For now, just restart the app and your wallet should now show the balance of the coins you sent to it:

![Screenshot 2024-01-21 at 23 57 00](https://github.com/belgian-bitcoin-embassy/mobile-dev-workshops/assets/92805150/5a9e85fa-57f1-4963-953b-f9f4a7e84620).

#### Refreshing the balance

To be able to refresh the balance, we will add a new method to the `HomeController` class, which will make use of the `sync` method of the `BitcoinWalletService` class to obtain the latest data from the blockchain:

```dart
// Add to `HomeController` class
Future<void> refresh() async {
  try {
    final state = _getState();
    if (state.walletBalance == null) {
      // No wallet to refresh
      return;
    }

    await (_bitcoinWalletService as BitcoinWalletService).sync();
    final balance = await _bitcoinWalletService.getSpendableBalanceSat();
    _updateState(
      state.copyWith(
        walletBalance: WalletBalanceViewModel(
          walletName: state.walletBalance!.walletName,
          balanceSat: balance,
        ),
      ),
    );
  } catch (e) {
    print(e);
    // ToDo: handle and set error state
  }
}
```

Flutter already has a `RefreshIndicator` widget that allows to call a refresh method when the user pulls down the screen. We will use this to call the `refresh` method of the `HomeController` when the user pulls down the `HomeScreen`. To do this, we will wrap the `body` of the `HomeScreen` with the `RefreshIndicator` widget and call the `refresh` method of the `HomeController` in the `onRefresh` callback:

```dart
// ... In `HomeScreen` widget
body: RefreshIndicator(
  onRefresh: () async {
    await _controller.refresh();
  },
  child: ListView(
    // ... rest of widget
  ),
),
```

That's it, now you should be able to pull down the `HomeScreen` to refresh the balance.
Try it out by sending some more coins to your wallet and then pull down the `HomeScreen` to refresh the balance.

### 5. Transaction history

Now that we have some receiving transactions, we can use them to make the transaction history have real and dynamic data. For this we will add a new method to the `BitcoinWalletService` class `getTransactions` to obtain the transaction history:

```dart
abstract class WalletService {
  Future<void> addWallet();
  Future<void> deleteWallet();
  Future<int> getSpendableBalanceSat();
  Future<String> generateInvoice();
  Future<List<TransactionEntity>> getTransactions(); // Add this
}
```

As you see we want it to return a List of transactions as `TransactionEntity` instances. We will create a new `TransactionEntity` class to hold the transaction data as we receive it from the blockchain. Create a folder called `entities` in the `lib` folder and create a new file called `transaction_entity.dart` in it.
We will not keep track of all fields or data of a transaction for now, but just the most basic fields like: transaction id, the amount of received utxo's, the amount of sent utxo's and the confirmation time. We will structure this data as follow:

```dart
@immutable
class TransactionEntity extends Equatable {
  final String id;
  final int receivedAmountSat;
  final int sentAmountSat;
  final int? timestamp;

  const TransactionEntity({
    required this.id,
    this.receivedAmountSat = 0,
    this.sentAmountSat = 0,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        receivedAmountSat,
        sentAmountSat,
        timestamp,
      ];
}
```

Since we will use this `TransactionEntity` in the future for other types of transactions, for example to get the history of Lightning payments, we put the default value for `receivedAmountSat` and `sentAmountSat` to 0, since in Lightning payments there is no concept of received and sent utxo's in a single transaction, but just of received or sent amounts.

Now we can add a concrete implementation of the `getTransactions` method to the `BitcoinWalletService` class. We will use the `listTransactions` method of our BDK `Wallet` instance to obtain the transactions and map them to our own `TransactionEntity` instances to not depend too much on the BDK library in the rest of the app:

```dart
@override
  Future<List<TransactionEntity>> getTransactions() async {
    final transactions = await _wallet!.listTransactions(true);

    return transactions.map((tx) {
      return TransactionEntity(
        id: tx.txid,
        receivedAmountSat: tx.received,
        sentAmountSat: tx.sent,
        timestamp: tx.confirmationTime?.timestamp,
      );
    }).toList();
  }
```

With that we can fetch the transaction history we need. Now we need to show that data in the UI. We previously created a widget for an item in the transaction list already, but it uses hardcoded mock data. Let's add a new view model to represent the data of a transaction that we want to show in this widget. Taking a look at the widget again, we need to show the following data dynamically for each transaction in the list:

- An arrow icon, pointing up or down, depending on if the user received or sent out more funds in the transaction.
- A title, also depending on if the user received more funds or sent out more funds in the transaction.
- A subtitle with the date and time of the transaction.
- The transaction amount positive or negative, depending on if the user received or sent out more funds in the transaction. It should be denominated in BTC for now.

Both the arrow icon and the title can be derived from the amount, since the direction of the transaction can be derived from it. So we only need one field for the amount in the view model instead of a separate one for the icon and title. We also do not need a separate field for the direction of the transaction, but we can add getter functions `isIncoming` and `isOutgoing` to the view model to derive this from the amount.

The view model should have an identifier of the transaction, this can be the same transaction id as the entity. Also the timestamp can be obtained from the timestamp of the entities we receive from the blockchain. The amount can be derived from the `receivedAmountSat` and `sentAmountSat` fields of the entity and we can add a getter again to convert it from sats to BTC. We can add a constructor to create the view model from a `TransactionEntity` instance, so we can easily map the entities to the view models.

The timestamp should be shown in a human readable format, so we can add another getter function to the view model to format the timestamp to a string.

Taking all of the above into account, create a file `transactions_list_item_view_model.dart` in the `view_models` folder and add the class `TransactionsListItemViewModel` with its fields and methods like this:

```dart
import 'package:mobile_dev_workshops/entities/transaction_entity.dart';
import 'package:equatable/equatable.dart';

class TransactionsListItemViewModel extends Equatable {
  final String id;
  final int amountSat;
  final int? timestamp;

  const TransactionsListItemViewModel({
    required this.id,
    required this.amountSat,
    this.timestamp,
  });

  TransactionsListItemViewModel.fromTransactionEntity(TransactionEntity entity)
      : id = entity.id,
        amountSat = entity.receivedAmountSat - entity.sentAmountSat,
        timestamp = entity.timestamp!;

  bool get isIncoming => amountSat > 0;
  bool get isOutgoing => amountSat < 0;
  double get amountBtc => amountSat / 100000000;

  String? get formattedTimestamp {
    if (timestamp == null) {
      return null;
    }

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  @override
  List<Object?> get props => [id, amountSat, timestamp];
}
```

We can now change the hardcoded data in the widget to use data of a view model instead. Add a field and parameter to `TransactionsListItem` widget and use it to show the data in the UI:

```dart
class TransactionsListItem extends StatelessWidget {
  const TransactionsListItem({super.key, required this.transaction}); // Add the transaction parameter

  final TransactionsListItemViewModel transaction; // Add this

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        child: Icon(
          transaction.isIncoming ? Icons.arrow_downward : Icons.arrow_upward, // Use the view model data
        ),
      ),
      title: Text(
        transaction.isIncoming ? 'Received funds' : 'Sent funds', // Use the view model data
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        transaction.formattedTimestamp ?? 'Pending', // Use the view model data or 'Pending' in case of no timestamp
        style: theme.textTheme.bodySmall,
      ),
      trailing: Text(
          '${transaction.isIncoming ? '+' : ''}${transaction.amountBtc} BTC', // Use the view model data
          style: theme.textTheme.bodyMedium),
    );
  }
}
```

Now the `TransactionList` widget should also be updated to have a list of `TransactionsListItemViewModel` instances as a parameter and use them to build the list of the transactions dynamically. The `itemCount` of the list should be the length of the list of view models and the `itemBuilder` should take the view model at the current index to build the `TransactionsListItem` widget:

```dart
class TransactionsList extends StatelessWidget {
  const TransactionsList({super.key, required this.transactions}); // Add the transactions parameter

  final List<TransactionsListItemViewModel> transactions; // Add this

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
              true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemBuilder: (ctx, index) {
            return TransactionsListItem(
              transaction: transactions[index], // Get the view model at the current index
            );
          },
          itemCount: transactions.length, // Use the length of the list of view models
        ),
      ],
    );
  }
}
```

Now the `HomeScreen` widget should be able to obtain the transactions from the `BitcoinWalletService` to pass it to the `TransactionsList` widget. This is where our state and controller comes in again to connect the data and logic with the UI. The controller updates the state with the data from the service and the UI consumes the data from the state.

First, let's add a field to the `HomeState` class to hold the fetched list of transactions:

```dart
@immutable
class HomeState extends Equatable {
  const HomeState({
    this.walletBalance,
    this.transactions = const [], // Add this
  });

  final WalletBalanceViewModel? walletBalance;
  final List<TransactionsListItemViewModel> transactions; // Add this

  HomeState copyWith({
    WalletBalanceViewModel? walletBalance,
    bool clearWalletBalance = false,
    List<TransactionsListItemViewModel>? transactions, // Add this
  }) {
    return HomeState(
      walletBalance:
          clearWalletBalance ? null : walletBalance ?? this.walletBalance,
      transactions: transactions ?? this.transactions, // Add this
    );
  }

  @override
  List<Object?> get props => [walletBalance, transactions]; // Add transactions to the props
}
```

In the `HomeController` class, create a private method `_getTransactions` to fetch the transactions from the `BitcoinWalletService`, map them to the view models and sort them by timestamp in descending order as needed for the UI as BDK does not guarantee the order of the transactions in the list it returns:

```dart
Future<List<TransactionsListItemViewModel>> _getTransactions() async {
  // Get transaction entities from the wallet
  final transactionEntities = await _bitcoinWalletService.getTransactions();
  // Map transaction entities to view models
  final transactions = transactionEntities
      .map((entity) =>
          TransactionsListItemViewModel.fromTransactionEntity(entity))
      .toList();
  // Sort transactions by timestamp in descending order
  transactions.sort((t1, t2) {
    if (t1.timestamp == null && t2.timestamp == null) {
      return 0;
    }
    if (t1.timestamp == null) {
      return -1;
    }
    if (t2.timestamp == null) {
      return 1;
    }
    return t2.timestamp!.compareTo(t1.timestamp!);
  });
  return transactions;
}
```

As with the balance of the wallet, the transaction history should be fetched when the home screen is initialized and when the user pulls down the screen to refresh the data.
So in the `init` and `refresh` methods of the `HomeController` we can call our recently created `_getTransactions` function to add the transactions list to the state:

```dart
// ... in `HomeController` class
Future<void> init() async {
  if ((_bitcoinWalletService as BitcoinWalletService).hasWallet) {
    _updateState(
      _getState().copyWith(
        walletBalance: WalletBalanceViewModel(
          walletName: walletName,
          balanceSat: await _bitcoinWalletService.getSpendableBalanceSat(),
        ),
        transactions: _getTransactions(), // Add this
      ),
    );
  } else {
    _updateState(_getState().copyWith(
      clearWalletBalance: true,
      transactions: [], // Add this
    ));
  }
}
// ... rest of class
Future<void> refresh() async {
  try {
    final state = _getState();
    if (state.walletBalance == null) {
      return;
    }

    await (_bitcoinWalletService as BitcoinWalletService).sync();
    final balance = await _bitcoinWalletService.getSpendableBalanceSat();
    _updateState(
      state.copyWith(
        walletBalance: WalletBalanceViewModel(
          walletName: state.walletBalance!.walletName,
          balanceSat: balance,
        ),
        transactions: await _getTransactions(), // Add this
      ),
    );
  } catch (e) {
    print(e);
  }
}
// ... rest of class
```

You can observe that we map the entities to the view models in the `init` and `refresh` methods and update the state with the list of view models. This is because we want to keep the entities as close to the data we receive from the blockchain as possible and only convert it to view models when we need to show it in the UI. This way we can easily change the view model without having to change the entities and the other way around. Our constructor `fromTransactionEntity` in our `TransactionsListItemViewModel` comes in handy here to easily map the entities to the view models.

With this in place, our transaction history is ready in the state to be consumed by the UI, only thing left is updating the `TransactionsList` in the `HomeScreen`:

```dart
// ... in `HomeScreen` widget
TransactionsList(
  transactions: _state.transactions, // Add this
),
// ... rest of widget
```

Now you should be able to see the real transaction history in the `HomeScreen` when you run the app and have some transactions in your wallet:

![Screenshot transaction history](https://github.com/belgian-bitcoin-embassy/mobile-dev-workshops/assets/92805150/b1a1a5e9-4a1c-4853-a9ae-5d4e26df1841)

You can now test the app by receiving some more coins and then refresh or restart the app to see the new transactions appear in the list.

In a production app, you could set up some streams or other way to refresh automatically when a new transaction was send or arrived. You would also want to add a way to load more transactions when the user scrolls to the bottom of the list, since the list of transactions can be very long and we don't want to load all of them at once. Also while the transactions and balance fetching is in process, you could add a loading indicator. To keep our focus on the Bitcoin functionalities and the BDK library, these are all things we will not do in this workshop, but you can do it yourself as an exercise if you want.

For now we will continue with our final part of this first workshop and finish our on-chain Bitcoin wallet by adding the ability to send funds.

### 6. Sending funds

Now that we are able to receive funds and show our transactions, we will add the ability to send funds to another address ourselves.
Let's start by working from the `BitcoinWalletService` back to the UI again. We will add a new method to the `WalletService` interface to send funds. To keep our `WalletService` interface generic for other transactions later, let's name the new function `pay` and let it take an `invoice` parameter of type `String`. This invoice can later be parsed as a normal Bitcoin address or BIP21 URI, as a Lightning Invoice, as an LNURL etc. For now we will only implement paying to a regular Bitcoin address.

```dart
abstract class WalletService {
  Future<void> addWallet();
  Future<void> deleteWallet();
  Future<int> getSpendableBalanceSat();
  Future<String> generateInvoice();
  Future<List<TransactionEntity>> getTransactions();
  Future<String> pay(
    String invoice, {
    int? amountSat,
    double? satPerVbyte,
    int? absoluteFeeSat,
  }); // Add this pay method
}
```

The BDK library offers a `TxBuilder` that is quite powerful because of the flexibility to build all sort of different Bitcoin transactions. We will use this to build the transaction, then we will use our wallet to sign it and broadcast it to the blockchain. Now let's use all of that to add a concrete implementation of the `pay` method to the `BitcoinWalletService` class:

```dart
@override
Future<String> pay(
  String invoice, {
  int? amountSat,
  double? satPerVbyte,
  int? absoluteFeeSat,
}) async {
  if (amountSat == null) {
    throw Exception('Amount is required for a bitcoin on-chain transaction!');
  }

  // Convert the invoice to an address
  final address = await Address.create(address: invoice);
  final script = await address
      .scriptPubKey(); // Creates the output scripts so that the wallet that generated the address can spend the funds
  var txBuilder = TxBuilder().addRecipient(script, amountSat);

  // Set the fee rate for the transaction
  if (satPerVbyte != null) {
    txBuilder = txBuilder.feeRate(satPerVbyte);
  } else if (absoluteFeeSat != null) {
    txBuilder = txBuilder.feeAbsolute(absoluteFeeSat);
  }

  final txBuilderResult = await txBuilder.finish(_wallet!);
  final sbt = await _wallet!.sign(psbt: txBuilderResult.psbt);
  final tx = await sbt.extractTx();
  await _blockchain.broadcast(tx);

  return tx.txid();
}
```

As you can see, we added some parameters to the `pay` method to be able to set the fee rate for the transaction. The `amountSat` parameter is required, since we need to know the amount to send. The `satPerVbyte` parameter is optional and can be used to set the fee rate in satoshis per vbyte. The `absoluteFeeSat` parameter is also optional and can be used to set the absolute fee in satoshis.

At the end we return the transaction id of the broadcasted transaction to be able to show it in the UI or to handle it in any other way.

Now to get the data from the send tab UI to the `BitcoinWalletService`, we will also add a state and controller for the send feature, similar to what we did for the receive feature.
In the `lib/features/wallet_actions/send` folder, add two new files: `send_state.dart` and `send_controller.dart`.

In the `send_state.dart` file, add the `SendState` class with fields for the inputs like the amount, the address and the fee rate, as well as some fields to show in the UI like possible errors and loading:

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class SendState extends Equatable {
  const SendState({
    this.amountSat,
    this.invoice,
    this.satPerVbyte,
    this.isMakingPayment = false,
    this.error,
    this.txId,
  });

  final int? amountSat;
  final String? invoice;
  final double? satPerVbyte;
  final bool isMakingPayment;
  final Exception? error;
  final String? txId;

  double? get amountBtc {
    if (amountSat == null) {
      return null;
    }

    return amountSat! / 100000000;
  }

  SendState copyWith({
    int? amountSat,
    String? invoice,
    double? satPerVbyte,
    bool? isMakingPayment,
    Exception? error,
    bool? clearError,
    String? txId,
  }) {
    return SendState(
      amountSat: amountSat ?? this.amountSat,
      invoice: invoice ?? this.invoice,
      satPerVbyte: satPerVbyte ?? this.satPerVbyte,
      isMakingPayment: isMakingPayment ?? this.isMakingPayment,
      error: clearError == true ? null : error ?? this.error,
      txId: txId ?? this.txId,
    );
  }

  String? get partialTxId {
    if (txId == null) {
      return null;
    }

    return '${txId!.substring(0, 8)}...${txId!.substring(txId!.length - 8)}';
  }

  @override
  List<Object?> get props => [
        amountSat,
        invoice,
        satPerVbyte,
        isMakingPayment,
        error,
        txId,
      ];
}
```

In the `send_controller.dart` file, add the `SendController` class. This controller, like our `HomeController` and `ReceiveController`, also needs access to the state, the `SendState` in this case, and the `BitcoinWalletService` to be able to send the payment. So also add the `getState`, `updateState` and the `WalletService` fields and set them in the constructor.
Add the methods to handle the input changes, for now we will skip the fee slider and only implement the amount and address input fields. Also add a method to handle the send button press:

```dart
import 'package:mobile_dev_workshops/features/wallet_actions/send/send_state.dart';
import 'package:mobile_dev_workshops/services/wallets/wallet_service.dart';

class SendController {
  final SendState Function() _getState;
  final Function(SendState state) _updateState;
  final WalletService _bitcoinWalletService;

  SendController({
    required getState,
    required updateState,
    required bitcoinWalletService,
  })  : _getState = getState,
        _updateState = updateState,
        _bitcoinWalletService = bitcoinWalletService;

  void amountChangeHandler(String? amount) async {
    final state = _getState();
    try {
      if (amount == null || amount.isEmpty) {
        _updateState(state.copyWith(amountSat: 0, clearError: true));
      } else {
        final amountBtc = double.parse(amount);
        final int amountSat = (amountBtc * 100000000).round();

        if (amountSat > await _bitcoinWalletService.getSpendableBalanceSat()) {
          _updateState(state.copyWith(
            error: NotEnoughFundsException(),
          ));
        } else {
          _updateState(state.copyWith(amountSat: amountSat, clearError: true));
        }
      }
    } catch (e) {
      print(e);
      _updateState(state.copyWith(
        error: InvalidAmountException(),
      ));
    }
  }

  void invoiceChangeHandler(String? invoice) async {
    if (invoice == null || invoice.isEmpty) {
      _updateState(_getState().copyWith(invoice: ''));
    } else {
      _updateState(_getState().copyWith(invoice: invoice));
    }
  }

  Future<void> makePayment() async {
    final state = _getState();
    try {
      _updateState(state.copyWith(isMakingPayment: true));

      final txId = await _bitcoinWalletService.pay(
        state.invoice!,
        amountSat: state.amountSat,
        satPerVbyte: state.satPerVbyte,
      );

      _updateState(state.copyWith(
        isMakingPayment: false,
        txId: txId,
      ));
    } catch (e) {
      print(e);
      _updateState(state.copyWith(
        isMakingPayment: false,
        error: PaymentException(),
      ));
    }
  }
}

class InvalidAmountException implements Exception {}

class NotEnoughFundsException implements Exception {}

class PaymentException implements Exception {}
```

Now we can use this in our `SendTab` UI. However, like with the previous screens, we have to change the `SendTab` to a `StatefulWidget` to be able to use the state and controller:

```dart
// ... in `send_tab.dart` change the `SendTab` class to a `StatefulWidget`
class SendTab extends StatefulWidget {
  const SendTab({super.key});

  @override
  SendTabState createState() => SendTabState();
}

class SendTabState extends State<SendTab> {
  // ... rest of class
```

Now we can add the state, the controller, initializing it in the `initState` method and the `WalletService` to the `SendTabState` class:

```dart
class SendTab extends StatefulWidget {
  const SendTab({required this.bitcoinWalletService, super.key}); // Add the bitcoinWalletService parameter

  final WalletService bitcoinWalletService; // Add this

  @override
  SendTabState createState() => SendTabState();
}

class SendTabState extends State<SendTab> {
  SendState _state = const SendState(); // Add the state
  late SendController _controller; // Add the controller

  // Add the initState method to initialize the controller
  @override
  void initState() {
    super.initState();

    _controller = SendController(
      getState: () => _state,
      updateState: (SendState state) => setState(() => _state = state),
      bitcoinWalletService: widget.bitcoinWalletService,
    );
  }
  // ... rest of class
```

Now we can use the state and controller in the UI of the `SendTab`. For the `onChanged` property of the amount and invoice `TextField`s we can set the `amountChangeHandler` and `invoiceChangeHandler` methods of the controller like this respectively: `onChanged: _controller.amountChangeHandler,` and `onChanged: _controller.invoiceChangeHandler,`.
For the `onPressed` property of the send button we can call the `makePayment` method of the controller. Taking into account that the button should only be active when an amount and invoice are entered, the amount is not higher than the spendable balance and there is no error, we can set the `onPressed` property of the button like this:

```dart
onPressed: _state.amountSat == null ||
        _state.amountSat == 0 ||
        _state.invoice == null ||
        _state.invoice!.isEmpty ||
        _state.error is InvalidAmountException ||
        _state.error is NotEnoughFundsException ||
        _state.isMakingPayment
    ? null
    : () => _controller.makePayment().then(
          (_) {
            if (_state.txId != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Payment successful. Tx ID: ${_state.partialTxId}'),
                ),
              );
              Navigator.pop(context);
            }
          },
        ),
```

We also disabled the button while the payment is in process by checking the `isMakingPayment` field of the state. To make it even more clear, let's change the icon of the button to also show a loading indicator when the payment is in process:

```dart
icon: _state.isMakingPayment
    ? const CircularProgressIndicator()
    : const Icon(Icons.send),
```

With the error field in the state, we can now also show the correct error message dynamically instead of always the same. Changes the condition in the `Text` widget to show the error message to this:

```dart
_state.error is InvalidAmountException
  ? 'Please enter a valid amount.'
  : _state.error is NotEnoughFundsException
      ? 'Not enough funds available.'
      : _state.error is PaymentException
          ? 'Failed to make payment. Please try again.'
          : '',
```

That should be it for the `SendTab` UI for now. Only thing left is making sure it gets the `WalletService` passed to it. Therefore just add it in the `wallet_actions_bottom_sheet.dart` file where the `SendTab` is used. Now both the `ReceiveTab` and the `SendTab` should have the `WalletService` passed to them:

```dart
child: TabBarView(
  children: [
    ReceiveTab(
      bitcoinWalletService: _bitcoinWalletService,
    ),
    SendTab(
      bitcoinWalletService: _bitcoinWalletService, // Add this
    ),
  ],
),
```

With no errors left, we can now make a payment. To do this, we need an address to send to. We can generate one on our simulated Bitcoin Core node in Polar. Bitcoin Core per default has wallet functionality. Polar doesn't expose all of this in the user interface, but it permits us to open a terminal by right clicking on the node and selecting `Launch Terminal`:

![Screenshot 2024-02-07 at 10 20 43](https://github.com/belgian-bitcoin-embassy/mobile-dev-workshops/assets/92805150/cb95e2fd-f680-424b-9deb-042ce3605916)

In the terminal we can use the `bitcoin-cli` command line interface to generate a new address. We can do this by running the following command:

```bash
bitcoin-cli getnewaddress
```

This should return us a new address like this:

![Screenshot 2024-02-07 at 18 35 30](https://github.com/belgian-bitcoin-embassy/mobile-dev-workshops/assets/92805150/0a504212-6dd7-448e-b737-7c3a1642bebb)

Now copy the address and go back to our app. In the app, tap on the floating action button, select the `Send` tab, enter an amount and paste the generated address. Now click on the button to send the payment. If you have some coins in your wallet, the payment should be broadcasted to the blockchain and you should see the transaction id printed to the console. When you refresh the app, you should see a pending transaction at the top of the list of transactions. If you mine some blocks in Polar, the transaction should be confirmed and the balance should be updated.

You may also notice that the amount is slightly more than the amount you entered. This is because of the fee that is added to the transaction. Since we didn't explicitly set the fee rate, the BDK library will calculate a minimum fee rate for us. In a production app, you would want to give the user the option to set the fee rate themselves, as different situations require different fee rates.

Even more, you could give the user the option to bump the fee of a pending transaction, to cancel a pending transaction or to replace a pending transaction with a new one. This is all possible with the BDK library and although we will not implement it in this workshop, let's explore the API of the TxBuilder a bit more to see how you could do this and some other interesting things if you'd like.

#### Bitcoin Development Kit's TxBuilder API

##### Fee bumping

It can happen that you put a fee that is too low and your transaction is not getting confirmed. This can happen for a lot of reasons and be accidentally or you could have put the fee low on purpose to save on fees and because you were not in a hurry to have it confirmed. In any case, you can bump the fee of a pending transaction at the moment you do need it confirmed sooner by creating a new transaction that spends the same utxo's but with a higher fee.

The original transaction does have to be flagged as replaceable by fee to be able to do this. Otherwise the mempool will not accept the new transaction. So if you want to make a transaction replaceable by fee, you should set the RBF (Replace-By-Fee) flag in the transaction:

```dart
TxBuilder().enableRbf();
```

If you then later need to replace this transaction, you can do this by using the `BumpFeeTxBuilder` class instead of the `TxBuilder` to build a transaction that will spend the same utxo's as the one build with `TxBuilder` originally. This method takes a `Txid` as a parameter, which is the transaction id of the transaction you want to bump the fee of. It also takes a `FeeRate` as a parameter, which is the new fee rate you want to use for the new transaction and should off course be higher than the fee rate of the original transaction:

```dart
BumpFeeTxBuilder(txid: <txId>, feeRate: <feeRate>);
```

The use of the `BumpFeeTxBuilder` is very similar to the `TxBuilder` and the `finish` method of the `BumpFeeTxBuilder` returns a `TxBuilderResult` that can be used to sign and broadcast the new transaction with the `Wallet` and `Blockchain` instance respectively.

There is one thing to keep in mind when bumping the fee of a transaction and that is that the new transaction will have a different transaction id than the original transaction. This means that the new transaction will be a different transaction than the original and the original will not be confirmed. This is because the transaction id is a hash of the transaction data and the transaction data includes the fee. So if the fee changes, the transaction id changes.

##### Coin selection or coin control

Coin selection is the process of selecting which utxo's to spend in a transaction. How you select the utxo's can be based on different strategies and can be done manually or automatically.

For privacy reasons it is considered a good practice to consciously select the utxo's to spend in a transaction. This is because the utxo's you spend in a transaction can be linked to each other and to you. If you spend utxo's that are not linked to each other and to you, it is harder for an observer to link them to you. You could for example not use a certain utxo in a transaction because it is linked to a certain other utxo that you don't want the receiver to know is yours. Or you may not want to use a big utxo in a small transaction because you don't want the receiver to know you have such a big utxo.

There are many things to take into consideration. If your users are not privacy conscious, you could use the [default coin selection strategy of the BDK library](https://docs.rs/bdk/latest/bdk/wallet/coin_selection/struct.BranchAndBoundCoinSelection.html), which is the Branch and Bound algorithm. This algorithm selects the utxo's that minimize the amount of change and the number of utxo's used by looking for a combination of utxo's that gives the exact amount needed in the transaction. This is a good strategy for most users, but is focused more on reducing fees and “dust” (or, worthless coins), not on optimizing privacy.

For users that do care about privacy, BDK does offer us the flexibility to implement our own coin selection strategy or implement a way to let the user select the utxo's manually. This is a bit more advanced and we will not implement it in this workshop, but it is good to know that it is possible. There are different methods available for this in the `TxBuilder` and `Wallet` classes of the BDK library:

```dart
TxBuilder().addUtxo(outpoint); // Add a specific utxo to spend in the transaction
TxBuilder().addUtxos(outpoints); // Add a list of specific utxo's to spend in the transaction
TxBuilder().doNotSpendChange(); // Makes sure no change utxo's are spent in the transaction
TxBuilder().addUnSpendable(unSpendable); // Add a specific utxo to not spend in the transaction
TxBuilder().manuallySelectedOnly(); // Makes sure only manually selected utxo's are spent in the transaction
TxBuilder().onlySpendChange(); // Makes sure only change utxo's are spent in the transaction
_wallet.listUnspent(); // List all utxo's of the wallet (_wallet is a Wallet instance)
```

Manual coin selection generally goes hand in hand with coin labeling. Coin labeling is the process of labeling utxo's with metadata to be able to select them manually. This metadata can be anything you want, for example a label to know the provenance of a utxo, like for example "payment dinner from Alice", "withdraw from exchange X" etc. This can help people to remember which utxo's are linked to each other and to them and to select them manually in a transaction. Some Bitcoiners use this to maintain a KYC-free utxo set, which is a set of utxo's that are not linked to their identity. Labeling utxo's is something not supported by the BDK library, but it is possible to implement it yourself by using the `Wallet` instance to list the utxo's and store the metadata in a database or file.

To get an idea of how the UX coin selection could be implemented, you can get inspired by the [Bitcoin Design Guide's chapter on Coin Selection](https://bitcoin.design/guide/how-it-works/coin-selection).

##### Drain wallet

Another interesting thing to mention is the `drain` method of the `Wallet` class. This method is used to spend all utxo's of the wallet (minus the ones added to the unspendable list) in a single transaction. This can be useful for example when you want to move all funds to a new wallet or to a new address. It can also be useful to consolidate utxo's to reduce the number of utxo's and to reduce the amount of change utxo's. This can be useful to reduce fees and to reduce the amount of dust in the wallet.

```dart
TxBuilder().draiWallet();
```

The method `drainTo` is a variant that will send the change utxo's of the transaction, in case you add utxo's that make the total amount exceed the amount to send to the recipient address, to a specific address instead of back to the wallet:

```dart
TxBuilder().drainTo(<script>);
```

#### Setting the fee rate

We already have the code in place to set the fee rate for a transaction in the `pay` method of the `BitcoinWalletService`. We can set the fee rate in satoshis per vbyte or we can set the absolute fee in satoshis. But how do we know what the fee rate to set should be? How does our user now what fee to set? This is a very important question and a very difficult one to answer. The fee rate is a very dynamic thing and depends on a lot of factors. It is not only the size of the transaction that determines the fee rate, but also the demand for block space. The demand for block space can change from minute to minute and so it is difficult to predict. This is why it is very difficult to set the fee rate and why it is a good practice to let the user set the fee rate themselves.

Let's do a quick intermezzo about fee rates in Bitcoin to understand this better.

##### Fee rate intermezzo

In Bitcoin, when making a transaction you are competing with other transactions to be included in a block. Bitcoin has a limited block size and miners try to maximize the profit they can make with the limited space they have in a block.
So generally you will have to pay a higher absolute fee for a bigger transaction (for example a tx with more inputs or outputs) then for a smaller transaction both wanting to be confirmed at a certain instance. So with the fee you are actually paying for the space you are taking up in a block. That's why fee rates are expressed in satoshis per vbyte. Like this you can compare the fee rates of different transactions, even if they have different sizes and different absolute fees.

Before SegWit, the size of a transaction was the size of the transaction in bytes and a block could only contain one megabyte of transactions. This meant that the fee rate was calculated by dividing the fee in satoshis by the size of the transaction in real bytes.

With SegWit, vbytes got introduced as the measuring unit instead. A vbyte is a virtual byte and one byte in a legacy transaction is equivalent to 4 weight units in a SegWit transaction. This is because the witness data of a SegWit transaction is discounted in the fee calculation, since it is not stored in the blockchain, but kept by the nodes that validate the transactions. Implicitly increasing the size that all transactions in a block can have to 4 megabytes, without increasing the block size limit itself, hereby avoiding a hard fork.

Except for making SegWit transactions occupy less space in a block and thus be cheaper, it also solved a problem of transaction malleability and made it possible to implement the Lightning Network. Diving deeper into SegWit is out of scope for this workshop, but it is good to know that the fee rate is expressed in satoshis per vbyte and that the fee rate is calculated by dividing the fee in satoshis by the size of the transaction in vbytes.

##### Fee estimation

Although different factors can influence the fee rate one needs or wants to set, we can use data from the mempool to estimate the fee rate. The mempool is the place on every node where all unconfirmed transactions are stored and so how much they are offering to pay in fees. The node our application is connected to through the BDK library also has its own copy of the mempool and can give us access to this data. This data can be used to estimate the fee rate we should set for our transaction to be confirmed in a certain amount of blocks. BDK exposes this data through the `Blockchain` class and its `estimateFee` method.

The `estimateFee` method takes a `Target` as a parameter, which is the amount of blocks you want to be confirmed in. Of course this is an estimation and not a guarantee, but it can give you an idea of what fee rate you should set.

We want to use this method to give the user an idea of what fee rate to set based on if his transaction is urgent or not. So let's create an entity class to hold different fee rates based on the priority of the transaction compared to other transactions in the mempool. In the `lib/entities` folder, add a new file `recommended_fee_rates_entity.dart` and add the `RecommendedFeeRatesEntity` class:

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class RecommendedFeeRatesEntity extends Equatable {
  final double highPriority;
  final double mediumPriority;
  final double lowPriority;
  final double noPriority;

  const RecommendedFeeRatesEntity({
    required this.highPriority,
    required this.mediumPriority,
    required this.lowPriority,
    required this.noPriority,
  });

  @override
  List<Object> get props => [
        highPriority,
        mediumPriority,
        lowPriority,
        noPriority,
      ];
}
```

Now we can use BDK's `estimateFee` method in our `BitcoinWalletService` to estimate the fee rates for different priorities and return them as a `RecommendedFeeRatesEntity`. Let's add a new method called `calculateFeeRates` to the `BitcoinWalletService`. We will not add this to the `WalletService` interface, because this way of returning the fee rates is specific to the Bitcoin blockchain and not to the Lightning Network for example.

```dart
Future<RecommendedFeeRatesEntity> calculateFeeRates() async {
    final [highPriority, mediumPriority, lowPriority, noPriority] =
        await Future.wait(
      [
        _blockchain.estimateFee(1),
        _blockchain.estimateFee(2),
        _blockchain.estimateFee(3),
        _blockchain.estimateFee(4),
      ],
    );

    return RecommendedFeeRatesEntity(
      highPriority: highPriority.asSatPerVb(),
      mediumPriority: mediumPriority.asSatPerVb(),
      lowPriority: lowPriority.asSatPerVb(),
      noPriority: noPriority.asSatPerVb(),
    );
  }
```

As the targets of blocks to get confirmed in we just took 1, 2, 3 and 4 blocks. This is just an example and you could use different targets based on your own criteria or based on the backend you are connected to. This latter is something important to mention, because the mempool of different nodes can have different data based on their mempool policies, and the way they calculate fees can also be different. So it is important to know which node you are connected to and to know how it calculates fees.

Since our local Polar RegTest node does not have pending transactions in a mempool, we will not be able to test this feature very well. So let's change the network and Bitcoin backend back to the Bitcoin mainnet where fee dynamics are the most interesting. Change the `_initBlockchain` method in the `BitcoinWalletService` to use Blockstream's Esplora API for the Bitcoin mainnet:

```dart
Future<void> _initBlockchain() async {
  _blockchain = await Blockchain.create(
    config: const BlockchainConfig.electrum(
      config: ElectrumConfig(
        retry: 5,
        url: "ssl://electrum.blockstream.info:50002", // The only difference with the testnet backend is the port number, 50002 instead of 60002
        validateDomain: false,
        stopGap: 10,
      ),
    ),
  );
}
```

Also change `Network.Regtest` to `Network.Bitcoin` in the other places where the network is used in the `BitcoinWalletService`.

Since we use Blockstream's Esplora backend, let's check the documentation to know how its fee estimation API works: https://github.com/Blockstream/esplora/blob/master/API.md#fee-estimates.

As you can see, it also returns the fee rates for different target blocks, but with a limited set of targets:

```
The available confirmation targets are 1-25, 144, 504 and 1008 blocks.
```

Also, if we navigate to `https://blockstream.info/api/fee-estimates` in our browser, we can see the fee rates for the different targets. Here are two observations you can check for yourself: Some block targets have the same fee rates and the proposed fee rates are different from the ones proposed by `mempool.space`. This is important to notice, because it shows that different backends can have different fee rates and that the fee rates can be different for different targets. Using the fee rates of Blockstream's Esplora as-is, your users might overpay for the priority they want. This is something to take into account when building a production app and it is important to know that the fee rates are not a guarantee and that they are just an estimation, so giving the user the option to set the fee rate themselves is a good practice.

Too have the most chance on having different fee rates without complicating ourself too much with the calculations, lets change the block targets in the `calculateFeeRates` method to 5, 144, 504 and 1008 blocks, using the available targets in the API response. This way we can see the difference in fee rates for different targets and we can use this to show the user the difference in fee rates for different priorities.

```dart
_blockchain.estimateFee(5),
_blockchain.estimateFee(144),
_blockchain.estimateFee(504),
_blockchain.estimateFee(1008),
```

Now we can use the `calculateFeeRates` method to show different fee rates in the `SendTab` UI. We can add a new method to the `SendController` to call the `calculateFeeRates` method and update the state with the fee rates. First we have to add a new field to the `SendState` to hold the fee rates. To keep it simple, just add a list of doubles to the `SendState`:

```dart
final List<double>? recommendedFeeRates;
```

Then we can add a new method to the `SendController` to call the `calculateFeeRates` method and update the state with the fee rates:

```dart
Future<void> fetchRecommendedFeeRates() async {
  final state = _getState();
  try {
    final fetchedRates = await (_bitcoinWalletService as BitcoinWalletService)
        .calculateFeeRates();

    final recommendedFeeRates = {
      fetchedRates.highPriority,
      fetchedRates.mediumPriority,
      fetchedRates.lowPriority,
      fetchedRates.noPriority
    }.toList();

    _updateState(
      state.copyWith(
        recommendedFeeRates: recommendedFeeRates,
        satPerVbyte: fetchedRates.mediumPriority,
      ),
    );
  } catch (e) {
    print(e);
    _updateState(state.copyWith(
      error: FeeRecommendationNotAvailableException(),
    ));
  }
}
```

In this method, we fetch the fees using the `BitcoinWalletService`, create a set to eliminate duplicate values and convert it to a list to set the `recommendedFeeRates` field of the state. We also set the `satPerVbyte` field of the state to the fee rate for the medium priority. We also catch any errors and set the error field of the state to show the user that the fee recommendation is not available.

Now we can call this method in the `initState` method of the `SendTab` to fetch the fee rates when the `SendTab` is opened:

```dart
@override
void initState() {
  super.initState();

  _controller = SendController(
    getState: () => _state,
    updateState: (SendState state) => setState(() => _state = state),
    bitcoinWalletService: widget.bitcoinWalletService,
  );

  _controller.fetchRecommendedFeeRates(); // Add this
}
```

Now we can use the state to make the `Slider` work and have the selected fee rate be shown:

```dart
// ... SendTab widget
// Fee rate slider
_state.recommendedFeeRates == null
    ? const CircularProgressIndicator()
    : SizedBox(
        width: 250,
        child: Column(
          children: [
            Slider(
              value: _state.satPerVbyte ?? 0,
              onChanged: null,
              divisions: _state.recommendedFeeRates!.length - 1,
              min: _state.recommendedFeeRates!.last,
              max: _state.recommendedFeeRates!.first,
              label: _state.satPerVbyte! <=
                      _state.recommendedFeeRates!.last
                  ? 'low priority'
                  : _state.satPerVbyte! >=
                          _state.recommendedFeeRates!.first
                      ? 'high priority'
                      : 'medium priority',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kSpacingUnit * 1.5,
              ),
              child: Text(
                'The fee rate to pay for this transaction: ${_state.satPerVbyte ?? 0} sat/vB.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
// ... rest of SendTab widget
```

The `Slider` will not work yet though, we still need the `onChanged` property to be set to a method that updates the state with the selected fee rate. We can add a new method to the `SendController` to do this and then add it to the `onChanged` property of the `Slider`:

```dart
// ... in the SendController class
void feeRateChangeHandler(double feeRate) {
  _updateState(_getState().copyWith(satPerVbyte: feeRate));
}
```

```dart
// ... in the Slider of the SendTab widget
onChanged: _controller.feeRateChangeHandler,
```

Now the `Slider` should work and the selected fee rate should be selected and shown like this:

![Slider](https://github.com/belgian-bitcoin-embassy/mobile-dev-workshops/assets/92805150/d5f3f24c-84f2-4c7b-86e4-e5692b4211d9)

The Slider experience might not be the best experience for a production app, but I hope you at least get the idea of how you could use the fee rates to show the user the difference in fee rates for different priorities and how you could let the user set the fee rate themselves.

### Bonus: Wallet Backup and Recovery

If time permits during the workshop we will add a way to show the mnemonic recovery phrase of the wallet from the menu and a way to recover a wallet from a mnemonic recovery phrase instead of only being able to create a new wallet.
