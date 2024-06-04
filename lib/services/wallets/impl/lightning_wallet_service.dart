import 'dart:async';
import 'dart:io';

import 'package:bolt11_decoder/bolt11_decoder.dart';
import 'package:mobile_dev_workshops/entities/transaction_entity.dart';
import 'package:mobile_dev_workshops/enums/wallet_type.dart';
import 'package:mobile_dev_workshops/repositories/mnemonic_repository.dart';
import 'package:mobile_dev_workshops/services/wallets/wallet_service.dart';
import 'package:ldk_node/ldk_node.dart';
import 'package:path_provider/path_provider.dart';

class LightningWalletService implements WalletService {
  final WalletType _walletType = WalletType.lightning;
  final MnemonicRepository _mnemonicRepository;
  Node? _node;

  LightningWalletService({
    required MnemonicRepository mnemonicRepository,
  }) : _mnemonicRepository = mnemonicRepository;

  @override
  WalletType get walletType => _walletType;

  @override
  Future<void> init() async {
    final mnemonic = await _mnemonicRepository.getMnemonic(_walletType.label);
    if (mnemonic != null && mnemonic.isNotEmpty) {
      await _initialize(Mnemonic(seedPhrase: mnemonic));

      print(
        'Lightning node initialized with id: ${(await _node!.nodeId()).hex}',
      );
    }
  }

  @override
  Future<void> addWallet() async {
    final mnemonic = await Mnemonic.generate();

    print('Generated mnemonic: ${mnemonic.seedPhrase}');

    await _mnemonicRepository.setMnemonic(
      _walletType.label,
      mnemonic.seedPhrase,
    );

    await _initialize(mnemonic);

    print(
      'Lightning Node added with node id: ${(await _node!.nodeId()).hex}',
    );
  }

  @override
  bool get hasWallet => _node != null;

  @override
  Future<void> deleteWallet() async {
    if (_node != null) {
      await _mnemonicRepository.deleteMnemonic(_walletType.label);
      await _node!.stop();
      await Future.delayed(const Duration(seconds: 12));
      await _clearCache();
      _node = null;
    }
  }

  @override
  Future<void> sync() async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }
    await _node!.syncWallets();

    await _printLogs();
  }

  @override
  Future<int> getSpendableBalanceSat() async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    final usableChannels =
        (await _node!.listChannels()).where((channel) => channel.isUsable);
    final outboundCapacityMsat = usableChannels.fold(
      0,
      (sum, channel) => sum + channel.outboundCapacityMsat,
    );

    return outboundCapacityMsat ~/ 1000;
  }

  Future<int> get inboundLiquiditySat async {
    if (_node == null) {
      return 0;
    }

    // 3. Get the total inbound liquidity in satoshis by summing up the inbound
    //  capacity of all channels that are usable and return it in satoshis.
    final usableChannels =
        (await _node!.listChannels()).where((channel) => channel.isUsable);
    final inboundCapacityMsat = usableChannels.fold(
      0,
      (sum, channel) => sum + channel.inboundCapacityMsat,
    );

    return inboundCapacityMsat ~/ 1000;
  }

  @override
  Future<(String?, String?)> generateInvoices({
    int? amountSat,
    int expirySecs = 3600 * 24, // Default to 1 day
    String description = 'BBE Workshop',
  }) async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    Bolt11Payment bolt11Payment = await _node!.bolt11Payment();
    Bolt11Invoice? bolt11;
    try {
      if (amountSat == null) {
        bolt11 = await bolt11Payment.receiveVariableAmountViaJitChannel(
          expirySecs: expirySecs,
          description: description,
        );
      } else {
        bolt11 = await bolt11Payment.receiveViaJitChannel(
          amountMsat: amountSat * 1000,
          expirySecs: expirySecs,
          description: description,
        );
      }
    } catch (e) {
      final errorMessage = 'Failed to generate invoice: $e';
      print(errorMessage);
    }

    final onChainPayment = await _node!.onChainPayment();
    final bitcoinAddress = await onChainPayment.newAddress();

    print('Generated invoice: ${bolt11?.signedRawInvoice}');
    print('Generated address: ${bitcoinAddress.s}');

    return (bitcoinAddress.s, bolt11 == null ? '' : bolt11.signedRawInvoice);
  }

  Future<int> get totalOnChainBalanceSat async {
    if (_node == null) {
      return 0;
    }

    final balances = await _node!.listBalances();
    return balances.totalOnchainBalanceSats;
  }

  Future<int> get spendableOnChainBalanceSat async {
    if (_node == null) {
      return 0;
    }

    final balances = await _node!.listBalances();
    return balances.spendableOnchainBalanceSats;
  }

  Future<String> drainOnChainFunds(String address) async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    final onChainPayment = await _node!.onChainPayment();
    final tx =
        await onChainPayment.sendAllToAddress(address: Address(s: address));
    return tx.hash;
  }

  Future<String> sendOnChainFunds(String address, int amountSat) async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    final onChainPayment = await _node!.onChainPayment();
    final tx = await onChainPayment.sendToAddress(
      address: Address(s: address),
      amountSats: amountSat,
    );
    return tx.hash;
  }

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

    await _node!.connectOpenChannel(
      socketAddress: SocketAddress.hostname(addr: host, port: port),
      nodeId: PublicKey(
        hex: nodeId,
      ),
      channelAmountSats: channelAmountSat,
      announceChannel: announceChannel,
      channelConfig: null,
      pushToCounterpartyMsat: null,
    );
  }

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

    final bolt11Payment = await _node!.bolt11Payment();
    final hash = amountSat == null
        ? await bolt11Payment.send(
            invoice: Bolt11Invoice(
              signedRawInvoice: invoice,
            ),
          )
        : await bolt11Payment.sendUsingAmount(
            invoice: Bolt11Invoice(
              signedRawInvoice: invoice,
            ),
            amountMsat: amountSat * 1000,
          );

    return hash.field0.toString();
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    final payments = await _node!.listPayments();

    return payments
        .where((payment) => payment.status == PaymentStatus.succeeded)
        .map((payment) {
      return TransactionEntity(
        id: payment.id.field0.toString(),
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

  Future<void> _initialize(Mnemonic mnemonic) async {
    // 1. Add the following url as the Rapid Gossip Sync server url to source
    //  the network graph data from: https://mutinynet.ltbl.io/snapshot
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
          address:
              const SocketAddress.hostname(addr: '44.219.111.31', port: 39735),
          publicKey: const PublicKey(
              hex:
                  '0371d6fd7d75de2d0372d03ea00e8bacdacb50c27d0eaea0a76a0622eff1f5ef2b'),
          token: 'JZWN9YLW',
        );

    _node = await builder.build();

    await _node!.start();
    await _printLogs();
  }

  Future<String> get _nodePath async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/ldk_cache";
  }

  Future<void> _clearCache() async {
    final directory = Directory(await _nodePath);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  Future<void> _printLogs() async {
    final logsFile = File('${await _nodePath}/logs/ldk_node_latest.log');
    String contents = await logsFile.readAsString();

    // Define the maximum length of each chunk to be printed
    const int chunkSize = 1024;

    // Split the contents into chunks and print each chunk
    for (int i = 0; i < contents.length; i += chunkSize) {
      int end =
          (i + chunkSize < contents.length) ? i + chunkSize : contents.length;
      print(contents.substring(i, end));
    }
  }
}

/*extension U8Array32X on U8Array32 {
  String get hexCode =>
      map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}*/
