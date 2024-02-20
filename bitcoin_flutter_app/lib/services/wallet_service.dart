import 'dart:io';

import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:bitcoin_flutter_app/entities/recommended_fee_rates_entity.dart';
import 'package:bitcoin_flutter_app/entities/transaction_entity.dart';
import 'package:bitcoin_flutter_app/enums/wallet_type.dart';
import 'package:bitcoin_flutter_app/repositories/mnemonic_repository.dart';
import 'package:ldk_node/ldk_node.dart' as ldk_node;

abstract class WalletService {
  Future<void> init();
  WalletType get walletType;
  Future<void> addWallet();
  bool get hasWallet;
  Future<void> deleteWallet();
  Future<int> getSpendableBalanceSat();
  Future<(String? bitcoinInvoice, String? lightningInvoice)> generateInvoices();
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
  Future<(String?, String?)> generateInvoices() async {
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

  LightningWalletService({
    required MnemonicRepository mnemonicRepository,
  }) : _mnemonicRepository = mnemonicRepository;

  @override
  Future<void> init() async {
    throw UnimplementedError();
  }

  @override
  WalletType get walletType => _walletType;

  @override
  Future<void> addWallet() async {}

  @override
  bool get hasWallet => _node != null;

  @override
  Future<void> deleteWallet() async {
    throw UnimplementedError();
  }

  @override
  Future<(String?, String?)> generateInvoices() async {
    // TODO: implement generateInvoice
    throw UnimplementedError();
  }

  @override
  Future<int> getSpendableBalanceSat() async {
    throw UnimplementedError();
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
}

class NoWalletException implements Exception {
  final String message;

  NoWalletException(this.message);
}
