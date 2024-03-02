import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:bitcoin_flutter_app/entities/recommended_fee_rates_entity.dart';
import 'package:bitcoin_flutter_app/entities/transaction_entity.dart';
import 'package:bitcoin_flutter_app/repositories/mnemonic_repository.dart';

abstract class WalletService {
  Future<void> addWallet();
  Future<void> deleteWallet();
  Future<int> getSpendableBalanceSat();
  Future<String> generateInvoice();
  Future<List<TransactionEntity>> getTransactions();
  Future<String> pay(
    String invoice, {
    int? amountSat,
    double? satPerVbyte,
    int? absoluteFeeSat,
  });
}

class BitcoinWalletService implements WalletService {
  final MnemonicRepository _mnemonicRepository;
  Wallet? _wallet;
  late Blockchain _blockchain;

  BitcoinWalletService({required MnemonicRepository mnemonicRepository})
      : _mnemonicRepository = mnemonicRepository;

  Future<void> init() async {
    print('Initializing BitcoinWalletService...');
    await _initBlockchain();
    print('Blockchain initialized!');

    final mnemonic = await _mnemonicRepository.getMnemonic();
    if (mnemonic != null && mnemonic.isNotEmpty) {
      await _initWallet(await Mnemonic.fromString(mnemonic));
      await sync();
      print('Wallet with mnemonic $mnemonic found, initialized and synced!');
    } else {
      print('No wallet found!');
    }
  }

  @override
  Future<void> addWallet() async {
    final mnemonic = await Mnemonic.create(WordCount.Words12);
    await _mnemonicRepository.setMnemonic(mnemonic.asString());
    await _initWallet(mnemonic);
    print(
        'Wallet added with mnemonic: ${mnemonic.asString()} and initialized!');
  }

  @override
  Future<void> deleteWallet() async {
    await _mnemonicRepository.deleteMnemonic();
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
  Future<String> generateInvoice() async {
    final invoice = await _wallet!.getAddress(
      addressIndex: const AddressIndex(),
    );

    return invoice.address;
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
    // 1. Check if an amount is provided since it's required for an on-chain transaction.
    //  throw an exception if it's not provided

    // 2. Convert the invoice string to a BDK Address

    // 3. Get a script that locks the output to the address

    // 4. Build a transaction and add the script as recipient and also set the amount

    // 5. Set the fee rate for the transaction based on the provided fee rate or absolute fee

    // 6. Finish the transaction building and sign it with the wallet

    // 7. Extract the transaction from the finalized and signed PSBT

    // 8. Broadcast the transaction to the network with the blockchain

    // 9. Return the transaction id
    return '<transaction_id>';
  }

  Future<RecommendedFeeRatesEntity> calculateFeeRates() async {
    // 10. Change the hardcoded fee rates to fees estimated by the blockchain data
    return const RecommendedFeeRatesEntity(
      highPriority: 35,
      mediumPriority: 30,
      lowPriority: 25,
      noPriority: 10,
    );
  }

  bool get hasWallet => _wallet != null;

  Future<void> sync() async {
    await _wallet!.sync(_blockchain);
  }

  Future<void> _initBlockchain() async {
    _blockchain = await Blockchain.create(
      config: const BlockchainConfig.electrum(
        config: ElectrumConfig(
          retry: 5,
          url: "ssl://electrum.blockstream.info:50002",
          validateDomain: false,
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
      network: Network.Bitcoin,
      databaseConfig: const DatabaseConfig
          .memory(), // Txs and UTXOs related to the wallet will be stored in memory
    );
  }

  Future<(Descriptor receive, Descriptor change)> _getBip84TemplateDescriptors(
    Mnemonic mnemonic,
  ) async {
    const network = Network.Bitcoin;
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
