import 'dart:async';
import 'dart:io';

import 'package:bitcoin_flutter_app/entities/transaction_entity.dart';
import 'package:bitcoin_flutter_app/enums/wallet_type.dart';
import 'package:bitcoin_flutter_app/repositories/mnemonic_repository.dart';
import 'package:ldk_node/ldk_node.dart' as ldk_node;
import 'package:path_provider/path_provider.dart';

abstract class WalletService {
  WalletType get walletType;
  Future<void> init();
  Future<void> addWallet();
  bool get hasWallet;
  Future<void> deleteWallet();
  Future<void> sync();
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

class LightningWalletService implements WalletService {
  final WalletType _walletType = WalletType.lightning;
  final MnemonicRepository _mnemonicRepository;
  ldk_node.Node? _node;
  late StreamController<ldk_node.Event> _eventController;
  late bool _stopEventStreamingFlag;
  late Future<void> _hasStreamingCompleted;

  LightningWalletService({
    required MnemonicRepository mnemonicRepository,
  }) : _mnemonicRepository = mnemonicRepository;

  @override
  WalletType get walletType => _walletType;

  @override
  Future<void> init() async {
    final mnemonic = await _mnemonicRepository.getMnemonic(_walletType.label);
    if (mnemonic != null && mnemonic.isNotEmpty) {
      await _initialize(ldk_node.Mnemonic(mnemonic));

      print(
        'Lightning node initialized with id: ${(await _node!.nodeId()).hexCode}',
      );
    }
  }

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

    await _initialize(mnemonic);
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
  Future<void> sync() async {
    await _node!.syncWallets();
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
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    final payments = await _node!.listPayments();

    return payments
        .where((payment) => payment.status == ldk_node.PaymentStatus.Succeeded)
        .map((payment) {
      return TransactionEntity(
        id: _convertU8Array32ToHex(payment.hash.data),
        receivedAmountSat:
            payment.direction == ldk_node.PaymentDirection.Inbound &&
                    payment.amountMsat != null
                ? payment.amountMsat! ~/ 1000
                : 0,
        sentAmountSat:
            payment.direction == ldk_node.PaymentDirection.Outbound &&
                    payment.amountMsat != null
                ? payment.amountMsat! ~/ 1000
                : 0,
        timestamp: null,
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
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    final hash = amountSat == null
        ? await _node!.sendPayment(
            invoice: ldk_node.Bolt11Invoice(
              signedRawInvoice: invoice,
            ),
          )
        : await _node!.sendPaymentUsingAmount(
            invoice: ldk_node.Bolt11Invoice(
              signedRawInvoice: invoice,
            ),
            amountMsat: amountSat * 1000,
          );
    print('Payment hash: ${_convertU8Array32ToHex(hash.data)}');
    return _convertU8Array32ToHex(hash.data);
  }

  Future<int> get totalOnChainBalanceSat => _node!.totalOnchainBalanceSats();

  Future<int> get spendableOnChainBalanceSat =>
      _node!.spendableOnchainBalanceSats();

  Future<void> openChannel({
    required String host,
    required int port,
    required String nodeId,
    required int channelAmountSat,
    bool announceChannel = true,
  }) async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }
    print('Opening channel to $nodeId with $channelAmountSat sats...');
    print('Host: $host, Port: $port');
    return _node!.connectOpenChannel(
      netaddress: ldk_node.SocketAddress.hostname(addr: host, port: port),
      nodeId: ldk_node.PublicKey(
        hexCode: nodeId,
      ),
      channelAmountSats: channelAmountSat,
      announceChannel: true,
    );
  }

  Future<String> drainOnChainFunds(String address) async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    final tx = await _node!
        .sendAllToOnchainAddress(address: ldk_node.Address(s: address));
    return tx.hash;
  }

  Future<String> sendOnChainFunds(String address, int amountSat) async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }
    final tx = await _node!.sendToOnchainAddress(
      address: ldk_node.Address(s: address),
      amountSats: amountSat,
    );
    return tx.hash;
  }

  Stream<ldk_node.Event> get events => _eventController.stream;

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
        .setNetwork(ldk_node.Network.Regtest)
        .setListeningAddresses(
      [
        const ldk_node.SocketAddress.hostname(addr: "0.0.0.0", port: 3004),
      ],
    );

    try {
      final node = await builder.build();
      return node;
    } catch (e) {
      print('Error building Lightning node: $e');
    }
    return builder.build();
  }

  Future<void> _initialize(ldk_node.Mnemonic mnemonic) async {
    _node = await _buildNode(mnemonic);
    await _node!.start();
    await _node!.syncWallets();
    // Start streaming events from the node
    _hasStreamingCompleted = _startEventStreaming();
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
    // Use a completer which will complete when the event streaming is stopped
    final Completer<void> completer = Completer<void>();
    // Reset the event streaming flag before starting the event streaming
    _stopEventStreamingFlag = false;
    // Create a new stream controller
    _eventController = StreamController<ldk_node.Event>.broadcast();

    Future.microtask(() async {
      while (true) {
        try {
          final e = await _node!.nextEvent().timeout(
                const Duration(seconds: 5),
                onTimeout: () => null,
              );
          if (e != null) {
            // Add the event to the stream
            _eventController.add(e);
            await _node!.eventHandled();
          }
          if (_stopEventStreamingFlag) {
            completer.complete();
            break;
          }
          // Wait a bit before checking for the next event
          await Future.delayed(const Duration(seconds: 5));
        } catch (e) {
          print('Error streaming events: $e');
        }
      }
    });

    return completer.future;
  }

  Future<void> _gracefulShutdown() async {
    // Stop streaming events before shutting down the node
    await _stopEventStreaming();
    await _node!.stop();
    await _clearCache();
    _node = null;
  }

  Future<void> _stopEventStreaming() async {
    _stopEventStreamingFlag = true;
    await _hasStreamingCompleted;
    await _eventController.close();
  }

  String _convertU8Array32ToHex(List<int> u8Array32) {
    return u8Array32
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}

class NoWalletException implements Exception {
  final String message;

  NoWalletException(this.message);
}
