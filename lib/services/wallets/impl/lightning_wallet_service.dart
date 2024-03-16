import 'dart:async';
import 'dart:io';

import 'package:mobile_dev_workshops/entities/transaction_entity.dart';
import 'package:mobile_dev_workshops/enums/wallet_type.dart';
import 'package:mobile_dev_workshops/repositories/mnemonic_repository.dart';
import 'package:mobile_dev_workshops/services/wallets/wallet_service.dart';
import 'package:ldk_node/ldk_node.dart';
import 'package:path_provider/path_provider.dart';

class LightningWalletService implements WalletService {
  final WalletType _walletType = WalletType.lightning;
  final MnemonicRepository _mnemonicRepository;
  // 1. Add ldk_node as a dependency
  Node? _node;
  late StreamController<Event> _eventController;
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
      await _initialize(Mnemonic(mnemonic));

      print(
        'Lightning node initialized with id: ${(await _node!.nodeId()).hexCode}',
      );
    }
  }

  @override
  Future<void> addWallet() async {
    Mnemonic mnemonic;

    String? storedMnemonic =
        await _mnemonicRepository.getMnemonic(_walletType.label);
    if (storedMnemonic == null || storedMnemonic.isEmpty) {
      mnemonic = await Mnemonic.generate();
      await _mnemonicRepository.setMnemonic(
        _walletType.label,
        mnemonic.seedPhrase,
      );

      print('New mnemonic generated and stored: ${mnemonic.seedPhrase}');
    } else {
      mnemonic = Mnemonic(storedMnemonic);
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
    final Bolt11Invoice bolt11;
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
        .where((payment) => payment.status == PaymentStatus.Succeeded)
        .map((payment) {
      return TransactionEntity(
        id: _convertU8Array32ToHex(payment.hash.data),
        receivedAmountSat: payment.direction == PaymentDirection.Inbound &&
                payment.amountMsat != null
            ? payment.amountMsat! ~/ 1000
            : 0,
        sentAmountSat: payment.direction == PaymentDirection.Outbound &&
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
      netaddress: SocketAddress.hostname(addr: host, port: port),
      nodeId: PublicKey(
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

    final tx =
        await _node!.sendAllToOnchainAddress(address: Address(s: address));
    return tx.hash;
  }

  Future<String> sendOnChainFunds(String address, int amountSat) async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }
    final tx = await _node!.sendToOnchainAddress(
      address: Address(s: address),
      amountSats: amountSat,
    );
    return tx.hash;
  }

  Stream<Event> get events => _eventController.stream;

  Future<Node> _buildNode(Mnemonic mnemonic) async {
    final builder = Builder()
        .setStorageDirPath(await _nodePath)
        .setEntropyBip39Mnemonic(mnemonic: mnemonic)
        .setEsploraServer(
          Platform.isAndroid
              ?
              //10.0.2.2 to access the AVD
              'http://10.0.2.2:3002'
              : 'http://127.0.0.1:3002',
        )
        .setNetwork(Network.Regtest)
        .setListeningAddresses(
      [
        const SocketAddress.hostname(addr: "0.0.0.0", port: 3003),
      ],
    );

    try {
      final node = await builder.build();
      return node;
    } catch (e) {
      throw Exception('Error building node');
    }
  }

  Future<void> _initialize(Mnemonic mnemonic) async {
    // 1. To create a Lightning Node instance, ldk_node provides a Builder class.
    //  Configure a Builder class instance by setting
    //    - the mnemonic as the entropy to create the node's wallet/keys from
    //    - the storage directory path to `_nodePath`,
    //    ...
    _node = await _buildNode(mnemonic);
    // 2. Build the node
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
    _eventController = StreamController<Event>.broadcast();

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
