# Workshop 3

In this third workshop we will integrate with a [Lightning Service Provider (LSP)](https://bitcoin.design/guide/how-it-works/lightning-services/) to take some of the burden to manage channels off of the user and enable receiving Lightning payments even without having inbound liquidity yet. We will also check some other services that can improve the user experience of a mobile Lightning node.

## Starting point

### Get the code

Checkout the `workshop-3` branch of this repository to get the starting point for this workshop:

```bash
git checkout workshop-3
```

### Head start

To implement a complete app including UI components, state management, controllers, repositories etc. we would need a lot more time and it would take us too far from the Lightning Network and `ldk_node` specific code. Therefore you get a head start. All needed widgets, screens, entities, view_models, repositories, controllers and state classes are already implemented and ready for you.

Take a look at the different files and folders in the [`lib`](./lib/) folder. This is the folder where the code of a Flutter/Dart app is located and where the code you will start off with is located.

### Run the app

Start the app to make sure the provided code is working.

```bash
flutter run
```

The code has all solutions from the previous workshops implemented already, so you should have a working self-custodial on-chain and lightning wallet.

### Wallet service

The place where we will implement the new features is the `LightningWalletService` class. This class is located in the [`lib/services/wallets/lightning_wallet_service.dart`](./lib/services/wallets/lightning_wallet_service.dart) file.

## Let's code

So let's start implementing the missing parts of the `LightningWalletService` class step by step.

Try to implement the steps yourself first and only then check the [solution](WORKSHOP_3_SOLUTIONS.md).

### Use an LSP for JIT channels
