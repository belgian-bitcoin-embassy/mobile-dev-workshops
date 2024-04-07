# Workshop 2 Solutions

Here you can find the solutions for the steps to implement in the second workshop. Try to implement the steps yourself first and only then check the solutions.

### Generating a new Lightning wallet

```dart
@override
Future<void> addWallet() async {
  // 1. Use ldk_node's Mnemonic class to generate a new, valid mnemonic
  final mnemonic = await Mnemonic.generate();

  await _mnemonicRepository.setMnemonic(
    _walletType.label,
    mnemonic.seedPhrase,
  );

  await _initialize(mnemonic);

  print(
    'Lightning Node added with node id: ${(await _node!.nodeId()).hexCode}',
  );
}
```

### Lightning Node setup

```dart
Future<void> _initialize(Mnemonic mnemonic) async {
  // 2. To create a Lightning Node instance, ldk_node provides a Builder class.
  //  Configure a Builder class instance by setting
  //    - the mnemonic as the entropy to create the node's wallet/keys from
  //    - the storage directory path to `_nodePath`,
  //    - the network to signet,
  //    - the Esplora server URL to `https://mutinynet.com/api/`
  //    - a listening addresses to 0.0.0.0:9735
  final builder = Builder()
        .setEntropyBip39Mnemonic(mnemonic: mnemonic)
        .setStorageDirPath(await _nodePath)
        .setNetwork(Network.signet)
        .setEsploraServer('https://mutinynet.com/api/')
        .setListeningAddresses(
            [const SocketAddress.hostname(addr: '0.0.0.0', port: 9735)]);
  // 3. Build the node from the builder and assign it to the `_node` variable
  //  so it can be used in the rest of the class.
  _node = await builder.build();
  // 4. Start the node
  await _node!.start();
}
```

### Get the spendable balance

```dart
@override
Future<int> getSpendableBalanceSat() async {
  if (_node == null) {
    throw NoWalletException('A Lightning node has to be initialized first!');
  }

  // 5. Get the balances of the node
  final balances = await _node!.listBalances();

  // 6. Return the total lightning balance
  return balances.totalLightningBalanceSats;
}
```

### Receive a payment

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

  // 7. Based on an amount of sats being passed or not, generate a bolt11 invoice
  //  to receive a fixed amount or a variable amount of sats.
  final Bolt11Invoice bolt11;
  if (amountSat == null) {
    bolt11 = await _node!.receiveVariableAmountPayment(
      expirySecs: expirySecs,
      description: description,
    );
  } else {
    bolt11 = await _node!.receivePayment(
      amountMsat: amountSat * 1000,
      expirySecs: expirySecs,
      description: description,
    );
  }

  // 8. As a fallback, also generate a new on-chain address to receive funds
  //  in case the sender doesn't support Lightning payments.
  final bitcoinAddress = await _node!.newOnchainAddress();

  // 9. Return the bitcoin address and the bolt11 invoice
  return (bitcoinAddress.s, bolt11.signedRawInvoice);
}
```

### Open a channel

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

  // 10. Connect to a node and open a new channel.
  final channelId = await _node!.connectOpenChannel(
    address: SocketAddress.hostname(addr: host, port: port),
    nodeId: PublicKey(
      hexCode: nodeId,
    ),
    channelAmountSats: channelAmountSat,
    announceChannel: announceChannel,
    channelConfig: null,
    pushToCounterpartyMsat: null,
  );

  // 11. Return the channel id as a hex string
  return hex.encode(channelId.data);
}
```

### Pay an invoice

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

  // 12. Use the node to send a payment.
  //  If the amount is not specified, suppose it is embeded in the invoice.
  //  If the amount is specified, suppose the invoice is a zero-amount invoice and specify the amount when sending the payment.
  final hash = amountSat == null
      ? await _node!.sendPayment(
          invoice: Bolt11Invoice(
            signedRawInvoice: invoice,
          ),
        )
      : await _node!.sendPaymentUsingAmount(
          invoice: Bolt11Invoice(
            signedRawInvoice: invoice,
          ),
          amountMsat: amountSat * 1000,
        );

  // 13. Return the payment hash as a hex string
  return hash.data.hexCode;
}
```

### Get payment history

```dart
@override
Future<List<TransactionEntity>> getTransactions() async {
  if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
  }

  // 14. Get all payments of the node
  final payments = await _node!.listPayments();

  // 15. Filter the payments to only include successful ones and return them as a list of `TransactionEntity` instances.
  return payments
      .where((payment) => payment.status == PaymentStatus.succeeded)
      .map((payment) {
      return TransactionEntity(
      id: payment.hash.data.hexCode,
      receivedAmountSat: payment.direction == PaymentDirection.inbound &&
              payment.amountMsat != null
          ? payment.amountMsat! ~/ 1000
          : 0,
      sentAmountSat: payment.direction == PaymentDirection.outbound &&
              payment.amountMsat != null
          ? payment.amountMsat! ~/ 1000
          : 0,
      timestamp: null,
      );
  }).toList();
}
```
