# Workshop 3

In this third workshop we will add a Rapid Gossip Sync server and integrate with a [Lightning Service Provider (LSP)](https://bitcoin.design/guide/how-it-works/lightning-services/) to take some of the burden to open channels off of the user and enable receiving Lightning payments even without having inbound liquidity yet. We will also check some other services that can improve the user experience of a mobile Lightning node.

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

### Rapid Gossip Sync

Everytime you (re)start a Lightning node, it needs to sync and verify the latest channel graph data of the network (commonly referred to as "gossip") to know the current state of the Lightning Network and how to route payments.
This can take a couple of minutes, which on a mobile phone, where the app and thus node is started and stopped frequently, can be a bit annoying when you want to make a payment quickly.

One solution that is applied by some mobile Lightning Network node wallets today is not having the gossip data on the device, but instead offloading the calculation of routing payments to a server. This approach however has some downsides, like privacy concerns, since the server will know all the payments of its users, and the need to trust the server to not manipulate the route calculation.

A better solution is to use a Rapid Gossip Sync server. This server serves a compact snapshot of the gossip network that can be used to bootstrap a node. This way the node can directly start with a recent snapshot of the gossip network and calculate routes itself, without the need to pass payment recipient information to a server.

To learn more about Rapid Gossip Sync and its intricacies, check out the [docs](https://lightningdevkit.org/blog/announcing-rapid-gossip-sync/).

LDK Node already has all the Rapid Gossip Sync client functionality implemented as you can see in the original [rust-lightning code](https://github.com/lightningdevkit/rust-lightning/blob/main/lightning-rapid-gossip-sync/src/lib.rs).

We just need to use it in our app by configuring the url of the Rapid Gossip Sync server we want to use in the `LightningWalletService` class. There are a couple of LSPs that provide Rapid Gossip Sync servers. Here are some examples for different networks you can use for development:

- https://rgs.mutinynet.com/snapshot/ for the Mutinynet Signet
- https://testnet.ltbl.io/snapshot for Testnet
- https://rapidsync.lightningdevkit.org/snapshot for Mainnet

Now add the url of the network you want to use to node builder in `_initialize` function of the `LightningWalletService` class:

```dart
Future<void> _initialize(Mnemonic mnemonic) async {
    // 1. Add the following url as the Rapid Gossip Sync server url to source
    //  the network graph data from: https://rgs.mutinynet.com/snapshot/
    final builder = Builder()
        .setEntropyBip39Mnemonic(mnemonic: mnemonic)
        .setStorageDirPath(await _nodePath)
        .setNetwork(Network.signet)
        .setEsploraServer('https://mutinynet.com/api/')
        .setListeningAddresses(
          [
            const SocketAddress.hostname(addr: '0.0.0.0', port: 9735),
          ],
        );

    _node = await builder.build();

    await _node!.start();
}
```

In the `sync` function, some logs are added to check if the Rapid Gossip Sync is working correctly. You can check the logs in the console to see if the sync is working.
A latest sync timestamp should be printed in the console after the sync is done.

### JIT channels with LSPS2

The next feature we will implement is the Just-In-Time (JIT) channels with LSPS2. This feature allows a wallet to receive a Lightning payment without having inbound liquidity yet. The LSP will open a zero-conf channel when it receives a payment for the wallet and pass the payment to through this channel. So the channel is created just in time when it is needed as the name suggests. A fee is generally deducted from the amount by the LSP for this service.

Various Liquidity Service Providers and Lightning wallets and developers are working on an open standard for this feature called [LSPS2](https://github.com/BitcoinAndLightningLayerSpecs/lsp/tree/main/LSPS2). Having a standard for this feature will make it easier for wallets to integrate with different LSPs and for LSPs to provide this service to different wallets, without the need for custom integrations for each wallet-LSP pair. This gives users more choice and competition in the market.

LDK Node already has the LSPS2 client functionality implemented and we can again just use it in our app by configuring the LSPS2 compatible LSP we want to use in the `LightningWalletService` class.

#### Set the LSPS2 Liquidity Source

To configure the LSPS2 compatible LSP you want to use, you need to know the public key/node id and the address of the Lightning Node of the LSP. Possibly an access token is also needed to use an LSP. You can get this information from the LSP you want to use.

For example, the following is the info of a node of the [C= (C equals)](https://cequals.xyz/) LSP on Mutinynet:

Node Pubkey: 0371d6fd7d75de2d0372d03ea00e8bacdacb50c27d0eaea0a76a0622eff1f5ef2b
Node Address: 44.219.111.31:39735
Token: JZWN9YLW

Use this information to configure the LSPS2 client in the `LightningWalletService` class:

```dart
Future<void> _initialize(Mnemonic mnemonic) async {
    // 2. Add the following LSP to be able to request LSPS2 JIT channels:
    //  Node Pubkey: 0371d6fd7d75de2d0372d03ea00e8bacdacb50c27d0eaea0a76a0622eff1f5ef2b
    //  Node Address: 44.219.111.31:39735
    //  Access token: JZWN9YLW
    final builder = Builder()
        .setEntropyBip39Mnemonic(mnemonic: mnemonic)
        .setStorageDirPath(await _nodePath)
        .setNetwork(Network.signet)
        .setEsploraServer('https://mutinynet.com/api/')
        .setListeningAddresses(
          [
            const SocketAddress.hostname(addr: '0.0.0.0', port: 9735),
          ],
        )
        .setGossipSourceRgs('https://rgs.mutinynet.com/snapshot');

    _node = await builder.build();

    await _node!.start();
}
```

Now we can request payments through LSPS2 JIT channels even if we don't have any channel yet or if we don't have inbound liquidity in our channels.

#### Check inbound liquidity

To be able to check the inbound liquidity, get the inbound liquidity from the node in the `inboundLiquiditySat` getter in the `LightningWalletService` class. The inbound liquidity is the sum of the inbound capacity of all channels of the node.

```dart
Future<int> get inboundLiquiditySat async {
    if (_node == null) {
      return 0;
    }

    // 3. Get the total inbound liquidity in satoshis by summing up the inbound
    //  capacity of all channels that are usable ad return it in satoshis.

    return 0;
}
```

#### Request JIT channels

Now we can change the `generateInvoices` function to request JIT channels from the LSPS2 compatible LSP when the inbound liquidity is not enough to receive a payment. We will also request a JIT channel when no amount is specified in the invoice, so we can receive any amount of payment without inbound liquidity problems.

```dart
@override
Future<(String?, String?)> generateInvoices({
    int? amountSat,
    int expirySecs = 3600 * 24, // Default to 1 day
    String description = 'BBE Workshop',
}) async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    final Bolt11Invoice bolt11;
    if (amountSat == null) {
        // 4. Change to receive via a JIT channel when no amount is specified
        bolt11 = await _node!.receiveVariableAmountPayment(
            expirySecs: expirySecs,
            description: description,
        );
    } else {
        // 5. Check the inbound liquidity and request a JIT channel if needed
        //  otherwise receive the payment as usual.
        bolt11 = await _node!.receivePayment(
            amountMsat: amountSat * 1000,
            expirySecs: expirySecs,
            description: description,
        );
    }

    final bitcoinAddress = await _node!.newOnchainAddress();

    return (bitcoinAddress.s, bolt11.signedRawInvoice);
}
```

In a real app, you could use other logic to decide when to request a JIT channel or give the user the option to choose if they want to use JIT channels or not.
