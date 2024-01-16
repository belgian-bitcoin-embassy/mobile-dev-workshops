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
    return Padding(
      padding: const EdgeInsets.all(kSpacingUnit * 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet actions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconLabelStackedButton(
                icon: Icons.arrow_downward,
                label: 'Receive funds',
                onPressed: () {
                  print('Receive funds');
                },
              ),
              IconLabelStackedButton(
                icon: Icons.arrow_upward,
                label: 'Send funds',
                onPressed: () {
                  print('Send funds');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

This widget adds a title and two buttons to the bottom sheet modal. The buttons are created with a custom widget called `IconLabelStackedButton` that we will create in the `lib/widgets/buttons` folder. This is another way to organize widgets, by type, instead of by feature. The `IconLabelStackedButton` widget as it name says will show an icon and a label stacked vertically. It will also have an `onPressed` callback to be able to do something when the button is pressed. The widget will look like this:

```dart
class IconLabelStackedButton extends StatelessWidget {
  const IconLabelStackedButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(kSpacingUnit * 5),
        child: Column(
          children: [
            CircleAvatar(
              child: Icon(icon),
            ),
            const SizedBox(height: kSpacingUnit),
            Text(label),
          ],
        ),
      ),
    );
  }
}
```

#### Wrap up

With this, we have the basic layout of our Bitcoin wallet app. It should look something like this now:

![Screenshot 2024-01-14 at 22 27 56](https://github.com/belgian-bitcoin-embassy/mobile-dev-workshops/assets/92805150/53016ef4-fd4e-4738-a002-fc745e413b6d)

![Screenshot 2024-01-14 at 22 28 10](https://github.com/belgian-bitcoin-embassy/mobile-dev-workshops/assets/92805150/a6c9242a-af0f-489d-a911-ce4b3bbfd7d5)

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

Then we create a new class called `SecureStorageMnemonicRepository` that will be a concrete implementation to store the mnemonic in secure storage. The `MnemonicRepositoryImpl` class will look like this:

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
    print('Wallet added with mnemonic: ${mnemonic.asString()}');
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

The copyWith method is used to create a new instance of the state with other values instead of mutating an existing instance. This is important for Flutter to know when the state has changed and rebuild the widget.

Now we can create the controller. In the same folder of the home feature, next to the screen and state, add the `home_controller.dart` file. The controller should be able to get the current state and update it. To do this, we will pass two callbacks to the controller, one to get the current state and one to update the state. This way, the controller does not need to know about the UI and the UI does not need to know about the controller. It should also have a dependency to the `WalletService` to be able to add and delete wallets. The `HomeController` will look like this:

```dart
class HomeController {
  final HomeState Function() _getState;
  final Function(HomeState state) _updateState;
  final WalletService _walletService;

  HomeController({
    required getState,
    required updateState,
    required walletService,
  })  : _getState = getState,
        _updateState = updateState,
        _walletService = walletService;

  Future<void> addNewWallet() async {
    try {
      await _walletService.addWallet();
      _updateState(
        _getState().copyWith(
          walletBalance: const WalletBalance(
            walletName: 'Savings',
          ),
        ),
      );
    } catch (e) {
      print(e);
      // An error can be added to the state here to show to the user, but this is not part of the workshop
    }
  }

  Future<void> deleteWallet() async {
    try {
      await _walletService.deleteWallet();
      _updateState(_getState().copyWith(clearWalletBalance: true));
    } catch (e) {
      print(e);
      // An error can be added to the state here to show to the user, but this is not part of the workshop
    }
  }
}
```

Now it is time to incorporate this state and the controller in the `HomeScreen` widget. First, we will add the state to the widget. To do this, we will use the `StatefulWidget` widget instead of the `StatelessWidget` widget. This way, we can use the `setState` method to update the state and rebuild the widget. The `HomeScreen` widget will now look like this:

```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  HomeState _state = const HomeState();
  late HomeController _controller;

  @override
  void initState() {
    super.initState();

    _controller = HomeController(
      getState: () => _state,
      updateState: (HomeState state) => setState(() => _state = state),
      walletService: BitcoinWalletService(
        mnemonicRepository: SecureStorageMnemonicRepository(),
      ),
    );
  }

  // ... rest of the widget
}
```

In production code, an instance of the `BitcoinWalletService` could be initalized at an higher level or as a Provider and the same instance could be used by the whole app, but for this workshop, we will just instantiate it in the `HomeScreen`.

We can now also use the state to show the correct widgets in the UI. We will use the `walletBalance` field of the state to show the `WalletBalanceCard` if it is not null and the `AddNewWalletCard` otherwise. For this we need to pass the `walletBalance` to the `WalletCardsList` widget and add callbacks to the `WalletCardsList` and `WalletBalanceCard` widgets to be able to add and delete wallets. Also the `WalletCardsList`, `WalletBalanceCard` and `AddNewWalletCard` widgets will be updated as follow:

```dart
// ... in the Scaffold of the HomeScreen widget
    child: WalletCardsList(
    _state.walletBalance == null ? [] : [_state.walletBalance!],
    onAddNewWallet: _controller.addNewWallet,
    onDeleteWallet: _controller.deleteWallet,
    ),
// ...

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
```

#### Obtaining the balance

To obtain the balance we will also use the Bitcoin Development Kit, through `bdk_flutter`, but to do this we need to dive a bit deeper in how this package works.

We will need to create a BDK `Wallet` and a `Blockchain` instance. The `Wallet` is to be able to derive addresses and create and sign transactions and the `Blockchain` instance is needed to sync with the Bitcoin blockchain to obtain the needed data, like the balance, and to broadcast our own transactions later.

We will initialize them both in our `WalletService`:

```dart

```

#### Checking for existing wallet

If the app is restarted, we

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
