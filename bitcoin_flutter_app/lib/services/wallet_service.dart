import 'dart:async';
import 'dart:io';

import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:bitcoin_flutter_app/entities/recommended_fee_rates_entity.dart';
import 'package:bitcoin_flutter_app/entities/transaction_entity.dart';
import 'package:bitcoin_flutter_app/enums/wallet_type.dart';
import 'package:bitcoin_flutter_app/repositories/mnemonic_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:ldk_node/ldk_node.dart' as ldk_node;
import 'package:path_provider/path_provider.dart';

abstract class WalletService {
  Future<void> init();
  WalletType get walletType;
  Future<void> addWallet();
  bool get hasWallet;
  Future<void> deleteWallet();
  Future<int> getSpendableBalanceSat();
  Future<(String? bitcoinInvoice, String? lightningInvoice)> generateInvoices({
    int? amountSat,
    int? expirySecs,
    String? description,
  });
  Future<List<TransactionEntity>> getTransactions();
  Future<String> pay(
    String invoice, {
    int? amountSat,
    double? satPerVbyte,
    int? absoluteFeeSat,
  });
}

class BitcoinWalletService implements WalletService {
  final WalletType _walletType = WalletType.onChain;
  final MnemonicRepository _mnemonicRepository;
  Wallet? _wallet;
  late Blockchain _blockchain;

  BitcoinWalletService({
    required MnemonicRepository mnemonicRepository,
  }) : _mnemonicRepository = mnemonicRepository;

  @override
  Future<void> init() async {
    print('Initializing BitcoinWalletService...');
    await _initBlockchain();
    print('Blockchain initialized!');

    final mnemonic = await _mnemonicRepository.getMnemonic(_walletType.label);
    if (mnemonic != null && mnemonic.isNotEmpty) {
      await _initWallet(await Mnemonic.fromString(mnemonic));
      await sync();
      print('Wallet with mnemonic $mnemonic found, initialized and synced!');
    } else {
      print('No wallet found!');
    }
  }

  @override
  WalletType get walletType => _walletType;

  @override
  Future<void> addWallet() async {
    Mnemonic mnemonic;
    String? storedMnemonic =
        await _mnemonicRepository.getMnemonic(_walletType.label);
    if (storedMnemonic == null || storedMnemonic.isEmpty) {
      mnemonic = await Mnemonic.create(WordCount.Words12);
      await _mnemonicRepository.setMnemonic(
        _walletType.label,
        mnemonic.asString(),
      );
    } else {
      mnemonic = await Mnemonic.fromString(storedMnemonic);
    }

    await _initWallet(mnemonic);
    print(
        'Wallet added with mnemonic: ${mnemonic.asString()} and initialized!');
  }

  @override
  bool get hasWallet => _wallet != null;

  @override
  Future<void> deleteWallet() async {
    await _mnemonicRepository.deleteMnemonic(_walletType.label);
    _wallet = null;
  }

  @override
  Future<int> getSpendableBalanceSat() async {
    final balance = await _wallet!.getBalance();

    print('Confirmed balance: ${balance.confirmed}');
    print('Spendable balance: ${balance.spendable}');
    print('Unconfirmed balance: ${balance.immature}');
    print('Trusted pending balance: ${balance.trustedPending}');
    print('Pending balance: ${balance.untrustedPending}');
    print('Total balance: ${balance.total}');

    return balance.spendable;
  }

  @override
  Future<(String?, String?)> generateInvoices({
    int? amountSat,
    int? expirySecs,
    String? description,
  }) async {
    final invoice = await _wallet!.getAddress(
      addressIndex: const AddressIndex(),
    );

    return (invoice.address, null);
  }

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

  Future<RecommendedFeeRatesEntity> calculateFeeRates() async {
    final [highPriority, mediumPriority, lowPriority, noPriority] =
        await Future.wait(
      [
        _blockchain.estimateFee(5),
        _blockchain.estimateFee(144),
        _blockchain.estimateFee(504),
        _blockchain.estimateFee(1008),
      ],
    );

    return RecommendedFeeRatesEntity(
      highPriority: highPriority.asSatPerVb(),
      mediumPriority: mediumPriority.asSatPerVb(),
      lowPriority: lowPriority.asSatPerVb(),
      noPriority: noPriority.asSatPerVb(),
    );
  }

  Future<void> sync() async {
    await _wallet!.sync(_blockchain);
  }

  Future<void> _initBlockchain() async {
    _blockchain = await Blockchain.create(
      config: BlockchainConfig.esplora(
        config: EsploraConfig(
          baseUrl: Platform.isAndroid
              ? "http://10.0.2.2:3002"
              : "http://127.0.0.1:3002",
          stopGap: 10,
        ),
      ),
    );
  }

  Future<void> _initWallet(Mnemonic mnemonic) async {
    final descriptors = await _getBip84TemplateDescriptors(mnemonic);
    _wallet = await Wallet.create(
      descriptor: descriptors.$1,
      changeDescriptor: descriptors.$2,
      network: Network.Regtest,
      databaseConfig: const DatabaseConfig
          .memory(), // Txs and UTXOs related to the wallet will be stored in memory
    );
  }

  Future<(Descriptor receive, Descriptor change)> _getBip84TemplateDescriptors(
    Mnemonic mnemonic,
  ) async {
    const network = Network.Regtest;
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
}

class LightningWalletService implements WalletService {
  final WalletType _walletType = WalletType.lightning;
  final MnemonicRepository _mnemonicRepository;
  ldk_node.Node? _node;
  bool _stopEventStreaming = false;
  late Future<void> _hasStreamingCompleted;

  final _eventController = StreamController<ldk_node.Event>.broadcast();

  Stream<ldk_node.Event> get events => _eventController.stream;

  LightningWalletService({
    required MnemonicRepository mnemonicRepository,
  }) : _mnemonicRepository = mnemonicRepository;

  @override
  Future<void> init() async {
    final mnemonic = await _mnemonicRepository.getMnemonic(_walletType.label);
    if (mnemonic != null && mnemonic.isNotEmpty) {
      _node = await _buildNode(ldk_node.Mnemonic(mnemonic));
      await _node!.start();
      await _node!.syncWallets();
      // Start streaming events from the node
      _hasStreamingCompleted = _startEventStreaming();

      // Open a channel
      /*await _node!.connectOpenChannel(
        netaddress:
            const ldk_node.SocketAddress.hostname(addr: '10.0.2.2', port: 9735),
        nodeId: const ldk_node.PublicKey(
          hexCode:
              '027860e3b909b36664fc1daf712d78ef766f6cdbb13fd7e4c75d27a0e98fb735fe',
        ),
        channelAmountSats: 500000,
        announceChannel: true,
      );

      await _node!.connectOpenChannel(
        netaddress:
            const ldk_node.SocketAddress.hostname(addr: '10.0.2.2', port: 9836),
        nodeId: const ldk_node.PublicKey(
          hexCode:
              '03256ee63dd615c492391a923fa786a40ce18f6a8c274f01a60f86426a14ea2648',
        ),
        channelAmountSats: 1000000,
        announceChannel: true,
      );*/
    }
  }

  @override
  WalletType get walletType => _walletType;

  @override
  Future<void> addWallet() async {
    ldk_node.Mnemonic mnemonic;

    String? storedMnemonic =
        await _mnemonicRepository.getMnemonic(_walletType.label);
    if (storedMnemonic == null || storedMnemonic.isEmpty) {
      mnemonic = await ldk_node.Mnemonic.generate();
      await _mnemonicRepository.setMnemonic(
        _walletType.label,
        mnemonic.seedPhrase,
      );

      print('New mnemonic generated and stored: ${mnemonic.seedPhrase}');
    } else {
      mnemonic = ldk_node.Mnemonic(storedMnemonic);
    }

    _node = await _buildNode(mnemonic);
    await _node!.start();
    await _node!.syncWallets();
    // Reset the event streaming flag before starting the event streaming
    _stopEventStreaming = false;
    // Start streaming events from the node
    _hasStreamingCompleted = _startEventStreaming();
    print(
      'Lightning Node added with node id: ${(await _node!.nodeId()).hexCode}',
    );
  }

  @override
  bool get hasWallet => _node != null;

  @override
  Future<void> deleteWallet() async {
    if (_node != null) {
      await _mnemonicRepository.deleteMnemonic(_walletType.label);
      await _gracefulShutdown();
    }
  }

  @override
  Future<(String?, String?)> generateInvoices({
    int? amountSat,
    int? expirySecs,
    String? description,
  }) async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    final bitcoinAddress = await _node!.newOnchainAddress();
    final ldk_node.Bolt11Invoice bolt11;
    const expirySecsDefault = 3600 * 24; // Default to 1 day

    if (amountSat == null) {
      final nodeId = await _node!.nodeId();
      bolt11 = await _node!.receiveVariableAmountPayment(
        nodeId: nodeId,
        expirySecs: expirySecs ?? expirySecsDefault, // Default to 1 day
        description: description ?? '',
      );
    } else {
      bolt11 = await _node!.receivePayment(
        amountMsat: amountSat,
        expirySecs: expirySecs ?? expirySecsDefault,
        description: description ?? '',
      );
    }

    return (bitcoinAddress.s, bolt11.signedRawInvoice);
  }

  @override
  Future<int> getSpendableBalanceSat() async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    final channels = await _node!.listChannels();
    final balanceMsat = channels.fold(
      0,
      (sum, channel) =>
          channel.isUsable ? sum + channel.outboundCapacityMsat : sum,
    );
    return balanceMsat ~/ 1000;
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    return [];
  }

  @override
  Future<String> pay(String invoice,
      {int? amountSat, double? satPerVbyte, int? absoluteFeeSat}) {
    // TODO: implement pay
    throw UnimplementedError();
  }

  Future<int> getOnChainBalance() async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    final balance = await _node!.totalOnchainBalanceSats();
    return balance;
  }

  Future<ldk_node.Node> _buildNode(ldk_node.Mnemonic mnemonic) async {
    final builder = ldk_node.Builder()
        .setStorageDirPath(await _nodePath)
        .setEntropyBip39Mnemonic(mnemonic: mnemonic)
        .setEsploraServer(
          Platform.isAndroid
              ?
              //10.0.2.2 to access the AVD
              'http://10.0.2.2:3002'
              : 'http://127.0.0.1:3002',
        )
        .setNetwork(ldk_node.Network.Regtest);

    try {
      final node = await builder.build();
      return node;
    } catch (e) {
      print('Error building Lightning node: $e');
    }
    return builder.build();
  }

  Future<String> get _nodePath async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/ldk_cache/";
  }

  Future<void> _clearCache() async {
    final directory = Directory(await _nodePath);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  Future<void> _startEventStreaming() {
    final Completer<void> completer = Completer<void>();

    Future.microtask(() async {
      while (true) {
        try {
          print('Waiting for next event...');
          final e = await _node!.nextEvent().timeout(
                const Duration(seconds: 5),
                onTimeout: () => null,
              );
          if (e != null) {
            print('Event: $e');
            _eventController.add(e);
            await _node!.eventHandled();
          }
          if (_stopEventStreaming) {
            print('Stopping event streaming...');
            completer.complete();
            break;
          }
          // Wait for a bit before checking for the next event
          await Future.delayed(const Duration(seconds: 10));
        } catch (e) {
          print('Error streaming events: $e');
        }
      }
      print('Event streaming stopped...');
    });

    return completer.future;
  }

  Future<void> _gracefulShutdown() async {
    print('Shutting down Lightning node...');
    _stopEventStreaming = true;
    print('Signalled to stop event stream...');
    await _hasStreamingCompleted;
    await _eventController.close();
    await _node!.stop();
    print('Node stopped...');
    await _clearCache();
    print('Cache cleared...');
    _node = null;

    print('Graceful shutdown complete!');
  }
}

class NoWalletException implements Exception {
  final String message;

  NoWalletException(this.message);
}
