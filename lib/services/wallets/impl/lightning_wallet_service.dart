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

      /*print(
        'Lightning node initialized with id: ${(await _node!.nodeId()).hexCode}',
      );*/
    }
  }

  @override
  Future<void> addWallet() async {
    // 2. Use ldk_node's Mnemonic class to generate a new, valid mnemonic
    final mnemonic = Mnemonic('invalid mnemonic');

    // 3. Use the MnemonicRepository to store the mnemonic in the device's
    //  secure storage with the wallet type label (_walletType.label) as the key.

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
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    // 7. Get all channels of the node and sum the usable channels' outbound capacity

    // 8. Return the balance in sats
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

    // 9. Based on an amount of sats being passed or not, generate a bolt11 invoice
    //  to receive a fixed amount or a variable amount of sats.

    // 10. As a fallback, also generate a new on-chain address to receive funds
    //  in case the sender doesn't support Lightning payments.

    // 11. Return the bitcoin address and the bolt11 invoice
    return ('invalid Bitcoin address', 'invalid bolt11 invoice');
  }

  Future<int> get totalOnChainBalanceSat => _node!.totalOnchainBalanceSats();

  Future<int> get spendableOnChainBalanceSat =>
      _node!.spendableOnchainBalanceSats();

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

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    // 15. Get all payments of the node

    // 16. Filter the payments to only include successful ones and return them as a list of `TransactionEntity` instances.
    return [];
  }

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

  String _convertU8Array32ToHex(List<int> u8Array32) {
    return u8Array32
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
