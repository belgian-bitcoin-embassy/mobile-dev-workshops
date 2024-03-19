# Workshop 2

The second workshop focuses on functionalities of a basic Lightning Network node/wallet, also called a spending wallet since it enables instant and low-fee payments and because of it being a hot wallet, it is not recommended to store large amounts of funds in it, only what you need for daily spending.

## Starting point

### Head start

To implement a complete app including UI components, state management, controllers, repositories etc. we would need a lot more time and it would take us too far from the Lightning Network and `ldk_node` specific code. Therefore you get a head start. All needed widgets, screens, entities, view_models, repositories, controllers and state classes are already implemented and ready for you.

Take a look at the different files and folders in the [`lib`](./lib/) folder. This is the folder where the code of a Flutter/Dart app is located.

### Local development

#### Polar

To not spend real bitcoin during development and have more control over the transaction progress, a local regtest network can be used. If you followed the instructions in the [prerequisites](./PREREQUISITES.md), you should have Polar installed and working.
Create a new regtest network with a Bitcoin node and some Lightning Network nodes and start the network.

#### Esplora

To be able to connect to the Bitcoin node from the LDK node library, an Electrum Server needs to run alongside the node, since the Polar node itself only exposes the Bitcoin Core RPC interface and not an Electrum RPC interface. To do this, we will use the Esplora Server implementation of mempool, named [electrs](https://github.com/mempool/electrs).

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

#### Lightning Development Kit (LDK)

In the previous workshop we used the Bitcoin Development Kit to build an on-chain wallet, in this workshop the [Lightning Development Kit (LDK)](https://lightningdevkit.org) will be used. It is a Rust library that permits creating a full-fledged Lightning Network node. A lot goes into creating a full Lightning Network node though, so luckily for us, a reference implementation for a full functional node build with LDK is available in another library called [LDK Node](https://github.com/lightningdevkit/ldk-node). This library also has a Flutter package that has bindings to the LDK Node library, so we can use it in our Flutter app and quickly have a real Lightning Node embedded and running on our mobile device. The Flutter package is called [ldk_node](https://pub.dev/packages/ldk_node) on pub.dev or [ldk-node-flutter](https://github.com/LtbLightning/ldk-node-flutter) on github.

To add LDK Node to our app, run the following command from inside the `mobile_dev_workshops` directory:

```bash
flutter pub add ldk_node
```

### Run the app

Start the app to make sure the provided code is working. You should see the user interface of the app, but it is based on hardcoded data and does not really permits you to do much yet.

### Wallet service

In the [`lib/services/wallets`](./lib/services/wallets) folder you can find the `wallet_service.dart` file. It provides an abstract `WalletService` class with the main functions a wallet service needs. In the [`impl`](./lib/services/wallets/impl/) folder a class `BitcoinWalletService` is provided and already implemented, this was done in the previous workshop #1. In this workshop, another implementation of the wallet service functions will be implemented in the `LightningWalletService` class to have a self-custodial Lightning wallet. We have left some code out of the `LightningWalletService` class for you to complete during the workshop.

## Let's code

So let's start implementing the missing parts of the `LightningWalletService` class step by step.

Try to implement the steps yourself first and only then check the [solution](#solutions).

### LDK Node

In the previous workshop we used the Bitcoin Development Kit to build an on-chain wallet, in this workshop the [Lightning Development Kit (LDK)](https://lightningdevkit.org/) will be used. Similar to the Bitcoin Development Kit, the Lightning Development Kit is a set of libraries to build Lightning wallets and applications. It is a Rust library that permits creating a full Lightning Network node. A lot goes into creating a full Lightning Network node though, so luckily for us, a reference implementation for a full functional node build with LDK is available in another library called [LDK Node](https://github.com/lightningdevkit/ldk-node). This library also has a Flutter package that has bindings to the LDK Node library, so we can use it in our Flutter app and quickly have a real Lightning Node embedded and running on our mobile device. The Flutter package is called [ldk_node](https://pub.dev/packages/ldk_node) on pub.dev or [ldk-node-flutter](https://github.com/LtbLightning/ldk-node-flutter) on github.

The principal class of the LDK Node library is the `Node` class. It is the main class that represents a Lightning Network node and will be used to open channels, send and receive payments, etc.
In the `LightningWalletService` class, a field of type `Node` is already declared, but it is giving an error because the `ldk_node` package is not yet added to the project.

```dart
class LightningWalletService implements WalletService {
    final WalletType _walletType = WalletType.lightning;
    final MnemonicRepository _mnemonicRepository;
    // 1. Add ldk_node as a dependency
    Node? _node;

    // ...
}
```

To add the LDK Node library to our app, run the following command:

```bash
flutter pub add ldk_node
```

### Generating a new Lightning wallet

A Lightning Node needs a seed phrase or mnemonic to derive private and public keys from to receive funds and sign transactions. So generating a mnemonic is the first thing to do when a user presses the `+ Add wallet: Spending` button in the app.
Pressing this button invokes a controller function and in the end calls the addWallet function of the `LightningWalletService` class. This function should generate a new mnemonic and then initialize the wallet by setting up the Lightning Node with it.

The code to generate the mnemonic is left out of the `addWallet` function in the `LightningWalletService` class for you to complete.

```dart
@override
Future<void> addWallet() async {
    // 2. Use ldk_node's Mnemonic class to generate a new, valid mnemonic
    final mnemonic = Mnemonic('invalid mnemonic');

    // 3. Use the MnemonicRepository to store the mnemonic in the device's
    //  secure storage with the wallet type label (_walletType.label) as the key.

    await _initialize(mnemonic);
    print(
        'Lightning Node added with node id: ${(await _node!.nodeId()).hexCode}',
    );
}
```

### Lightning Node setup

After generating the mnemonic, the `addWallet` function calls the `_initialize` function to set up the Lightning Node with the generated mnemonic. The `_initialize` function is not implemented and should be implemented by you:

```dart
Future<void> _initialize(Mnemonic mnemonic) async {
    // 4. To create a Lightning Node instance, ldk_node provides a Builder class.
    //  Configure a Builder class instance by setting
    //    - the mnemonic as the entropy to create the node's wallet/keys from
    //    - the storage directory path to `_nodePath`,
    //    - the network to Signet,
    //    - the Esplora server URL to `https://mutinynet.com/api/`
    //    - a listening addresses to 0.0.0.0:9735

    // 5. Build the node from the builder and assign it to the `_node` variable
    //  so it can be used in the rest of the class.

    // 6. Start the node

}
```

### Get the spendable balance

To get the real balance of the node, the `getSpendableBalanceSat` function should be implemented.
The amount that can be spend is the sum of the outbound capacity of all channels that are usable.

```dart
@override
  Future<int> getSpendableBalanceSat() async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    // 7. Get all channels of the node and sum the usable channels' outbound capacity

    // 8. Return the balance in sats
}
```

### Receive a payment

In the Lightning Network, the standard way to request payments is by creating invoices. Invoices with a prefixed amount are most common and most secure, but invoices without a prefixed amount can also be created, they are generally called zero-amount invoices.

In the app we use the BIP21 format, also known as unified QR codes. This format permits to encode both Bitcoin addresses and Lightning Network invoices in the same QR code. This can be used to share a Bitcoin address as a fallback in case the sender does not support Lightning payments. So the `generateInvoices` function should return both a Bitcoin address and a Lightning Network invoice as a tuple, so the app can generate a QR code with both.

```dart
@override
Future<(String?, String?)> generateInvoices({
    int? amountSat,
    int expirySecs = 3600 * 24, // Default to 1 day
    String? description,
}) async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    // 9. Based on an amount of sats being passed or not, generate a bolt11 invoice
    //  to receive a fixed amount or a variable amount of sats.

    // 10. As a fallback, also generate a new on-chain address to receive funds
    //  in case the sender doesn't support Lightning payments.

    // 11. Return the bitcoin address and the bolt11 invoice
    return ('invalid Bitcoin address', 'invalid bolt11 invoice');
}
```

Once you have implemented the generateInvoices correctly, you should be able to see the QR code of the generated invoice in the app when you press the `Generate invoice` button in the Receive tab of the wallet actions with the spending wallet selected.

If you try to pay this invoice through the mutinynet faucet though, you will see that the payment will fail. This is because your node does not have any channels yet. First an on-chain bitcoin address needs to be funded and a channel needs to be opened before payments can be made.

So use the faucet to send some funds to the bitcoin address generated with the spending wallet.

> [!NOTE]  
> The LDK Node library uses the Bitcoin Development Kit under the hood to manage on-chain transactions and addresses. But it does not expose all the functionalities of the Bitcoin Development Kit. Mainly just receiving and sending funds without much control and obtaining the on-chain balances, respectively with `ldk_node` functions `sendToOnchainAddress`, `sendAllToOnchainAddress`, `totalOnchainBalanceSats` and `spendableOnchainBalanceSats` . These latter functionalities are used in some implemented functions of the `LightningWalletService` class already. If you want more on-chain functionalities and control, you will have to use the Bitcoin Development Kit directly and add a separate savings wallet as we did in the previous workshop and have in the provided code.

### Open a channel

Connect and open a channel with a node from which the host, port and node id are passed as parameters. The channel amount is also passed as a parameter and the channel is not announced by default, since this is a mobile wallet and not a routing node.

```dart
Future<void> openChannel({
    required String host,
    required int port,
    required String nodeId,
    required int channelAmountSat,
    bool announceChannel = false,
}) async {
    if (_node == null) {
        throw NoWalletException('A Lightning node has to be initialized first!');
    }

    // 12. Connect to a node and open a new channel.

}
```

To get the option to open a channel, press the pending balance in the transactions overview, which should appear if you have sent funds to the bitcoin address of the spending wallet and the transaction has been confirmed.

### Pay an invoice

Now that the wallet was funded and a channel was opened, you have outbound capacity and should be able to pay invoices from the 'Send funds' tab in the wallet actions bottom sheet.

When the button is pressed, calls propogate through the controller and the `pay` function of the `LightningWalletService` class is called. This function should pay the invoice with the given bolt11 string.

```dart
@override
Future<String> pay(
String invoice, {
int? amountSat,
double? satPerVbyte, // Not used in Lightning
int? absoluteFeeSat, // Not used in Lightning
}) async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    // 13. Use the node to send a payment.
    //  If the amount is not specified, suppose it is embeded in the invoice.
    //  If the amount is specified, suppose the invoice is a zero-amount invoice and specify the amount when sending the payment.

    // 14. Return the payment hash as a hex string
    return _convertU8Array32ToHex([]);
}
```

Try to make some payments with the app to other nodes on mutinynet and see if they are successful.
You can get invoices from the mutinynet faucet's lightning address here: https://www.lnurlpay.com/refund@lnurl-staging.mutinywallet.com. You can also try to send to other participants in the workshop.

### Get payment history

Now that we are able to send and receive payments, we should also be able to see the payment history in the app. You can get this to work by implementing the `getTransactions` function in the `LightningWalletService` class.

```dart
@override
Future<List<TransactionEntity>> getTransactions() async {
    if (_node == null) {
        throw NoWalletException('A Lightning node has to be initialized first!');
    }

    // 15. Get all payments of the node

    // 16. Filter the payments to only include successful ones and return them as a list of `TransactionEntity` instances.
    return [];
}
```
