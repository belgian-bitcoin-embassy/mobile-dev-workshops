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

      /*print(
        'Lightning node initialized with id: ${(await _node!.nodeId()).hexCode}',
      );*/
    }
  }

  @override
  Future<void> addWallet() async {
    // 1. Use ldk_node's Mnemonic class to generate a new, valid mnemonic
    final mnemonic = Mnemonic(seedPhrase: 'invalid mnemonic');

    await _mnemonicRepository.setMnemonic(
      _walletType.label,
      mnemonic.seedPhrase,
    );

    await _initialize(mnemonic);

    /*print(
      'Lightning Node added with node id: ${(await _node!.nodeId()).hexCode}',
    );*/
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
  }

  @override
  Future<int> getSpendableBalanceSat() async {
    if (_node == null) {
      return 0;
    }

    // 5. Get the balances of the node

    // 6. Return the total lightning balance
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

    // 7. Based on an amount of sats being passed or not, generate a bolt11 invoice
    //  to receive a fixed amount or a variable amount of sats.

    // 8. As a fallback, also generate a new on-chain address to receive funds
    //  in case the sender doesn't support Lightning payments.

    // 9. Return the bitcoin address and the bolt11 invoice
    return ('invalid Bitcoin address', 'invalid bolt11 invoice');
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

    // 10. Connect to a node and open a new channel.

    // 11. Return the channel id as a hex string
    return hex.encode([]);
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

    // 12. Use the node to send a payment.
    //  If the amount is not specified, suppose it is embeded in the invoice.
    //  If the amount is specified, suppose the invoice is a zero-amount invoice and specify the amount when sending the payment.

    // 13. Return the payment hash as a hex string
    return '0x';
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    // 14. Get all payments of the node

    // 15. Filter the payments to only include successful ones and return them as a list of `TransactionEntity` instances.
    return [];
  }

  Future<void> _initialize(Mnemonic mnemonic) async {
    // 2. To create a Lightning Node instance, ldk_node provides a Builder class.
    //  Configure a Builder class instance by setting
    //    - the mnemonic as the entropy to create the node's wallet/keys from
    //    - the storage directory path to `_nodePath`,
    //    - the network to Signet,
    //    - the Esplora server URL to `https://mutinynet.com/api/`
    //    - a listening addresses to 0.0.0.0:9735

    // 3. Build the node from the builder and assign it to the `_node` variable
    //  so it can be used in the rest of the class.

    // 4. Start the node
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
}

extension U8Array32X on U8Array32 {
  String get hexCode =>
      map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}
