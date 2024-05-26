import 'dart:async';
import 'dart:io';

import 'package:mobile_dev_workshops/entities/transaction_entity.dart';
import 'package:mobile_dev_workshops/enums/wallet_type.dart';
import 'package:mobile_dev_workshops/repositories/mnemonic_repository.dart';
import 'package:mobile_dev_workshops/services/wallets/wallet_service.dart';
import 'package:ldk_node/ldk_node.dart';
import 'package:path_provider/path_provider.dart';
import 'package:convert/convert.dart';

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
        'Lightning node initialized with id: ${(await _node!.nodeId()).hexCode}',
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
      'Lightning Node added with node id: ${(await _node!.nodeId()).hexCode}',
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

    // The following code is just to check that the Rapid Gossip Sync is working
    final status = await _node!.status();
    print(
      'Latest Rapid Gossip Sync timestamp: ${status.latestRgsSnapshotTimestamp}',
    );
    final logsFile = File('${await _nodePath}/logs/ldk_node_latest.log');
    print(await logsFile.readAsString());
  }

  @override
  Future<int> getSpendableBalanceSat() async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    final balances = await _node!.listBalances();

    return balances.totalLightningBalanceSats;
  }

  Future<int> get inboundLiquiditySat async {
    if (_node == null) {
      return 0;
    }

    // 3. Get the total inbound liquidity in satoshis by summing up the inbound
    //  capacity of all channels that are usable and return it in satoshis.
    return 0;
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

  Future<String> openChannel({
    required String host,
    required int port,
    required String nodeId,
    required int channelAmountSat,
    bool announceChannel = false,
  }) async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

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

    return hex.encode(channelId.data);
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

    return hash.data.hexCode;
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
    );

    _node = await builder.build();

    await _node!.start();
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
}

extension U8Array32X on U8Array32 {
  String get hexCode =>
      map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}
