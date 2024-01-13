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

#### Balances

We will use a horizontal list of balances of the wallets created in the app, so that we can easily add more wallets in the future, like Lightning, etc. For now, we will only have an on-chain Bitcoin balance, but we will add a Lightning balance in the next workshop.

Use a ListView to display the balances horizontally.

- add assets folder and add it to pubspec.yaml
- Install svg package flutter_svg: flutter pub add flutter_svg

#### Transactions

ListView of transactions, with a ListTile for each transaction. The ListTile will have a leading widget with the day and month, a title, and the amount.

#### Floating button

The floating button will open a bottom sheet with possible actions. For now, we will only have the option to receive bitcoin, scan a QR and send bitcoin.

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
