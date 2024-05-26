# Workshop 3 Solutions

Here you can find the solutions for the steps to implement in the third workshop. Try to implement the steps yourself first and only then check the solutions.

### Rapid Gossip Sync

```dart
Future<void> _initialize(Mnemonic mnemonic) async {
    // 1. Add the following url as the Rapid Gossip Sync server url to source
    //  the network graph data from: https://rgs.mutinynet.com/snapshot/
    final builder = Builder()
        .setEntropyBip39Mnemonic(mnemonic: mnemonic)
        .setStorageDirPath(await _nodePath)
        .setNetwork(Network.signet)
        .setEsploraServer('https://mutinynet.ltbl.io/api')
        .setListeningAddresses(
          [
            const SocketAddress.hostname(addr: '0.0.0.0', port: 9735),
          ],
        )
        .setGossipSourceRgs('https://mutinynet.ltbl.io/snapshot');

    _node = await builder.build();

    await _node!.start();
}
```

### JIT channels with LSPS2

#### Set the LSPS2 Liquidity Source

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
        .setEsploraServer('https://mutinynet.ltbl.io/api')
        .setListeningAddresses(
          [
            const SocketAddress.hostname(addr: '0.0.0.0', port: 9735),
          ],
        )
        .setGossipSourceRgs('https://mutinynet.ltbl.io/snapshot')
        .setLiquiditySourceLsps2(
          address: const SocketAddress.hostname(
            addr: '44.228.24.253',
            port: 9735,
          ),
          publicKey: const PublicKey(
            hexCode:
                '025804d4431ad05b06a1a1ee41f22fefeb8ce800b0be3a92ff3b9f594a263da34e',
          ),
          token: 'JZWN9YLW',
        );

    _node = await builder.build();

    await _node!.start();
}
```

#### Check inbound liquidity

```dart
Future<int> get inboundLiquiditySat async {
    if (_node == null) {
      return 0;
    }

    // 3. Get the total inbound liquidity in satoshis by summing up the inbound
    //  capacity of all channels that are usable and return it in satoshis.
    final usableChannels = (await _node!.listChannels()).where(
      (channel) => channel.isUsable,
    );
    final inboundCapacityMsat = usableChannels.fold(
      0,
      (sum, channel) => sum + channel.inboundCapacityMsat,
    );

    return inboundCapacityMsat ~/ 1000;
}
```

#### Request JIT channels

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
        bolt11 = await _node!.receiveVariableAmountPaymentViaJitChannel(
            expirySecs: expirySecs,
            description: description,
        );
    } else {
        // 5. Check the inbound liquidity and request a JIT channel if needed
        //  otherwise receive the payment as usual.
        if (await inboundLiquiditySat < amountSat) {
            bolt11 = await _node!.receivePaymentViaJitChannel(
                amountMsat: amountSat * 1000,
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
    }

    final bitcoinAddress = await _node!.newOnchainAddress();

    return (bitcoinAddress.s, bolt11.signedRawInvoice);
}
```
