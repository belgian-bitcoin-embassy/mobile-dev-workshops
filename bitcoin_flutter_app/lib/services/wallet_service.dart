import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:bitcoin_flutter_app/repositories/mnemonic_repository.dart';

abstract class WalletService {
  Future<void> addWallet();
  Future<void> deleteWallet();
  Future<int> getSpendableBalanceSat();
  Future<String> generateInvoice();
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

  bool get hasWallet => _wallet != null;

  Future<void> sync() async {
    await _wallet!.sync(_blockchain);
  }

  Future<void> _initBlockchain() async {
    _blockchain = await Blockchain.create(
        // 1. Change the blockchain configuration to use the local Esplora server
        );
  }

  Future<void> _initWallet(Mnemonic mnemonic) async {
    final descriptors = await _getBip84TemplateDescriptors(mnemonic);
    _wallet = await Wallet.create(
      descriptor: descriptors.$1,
      changeDescriptor: descriptors.$2,
      network: // 2. Use the Regtest network
      databaseConfig: const DatabaseConfig
          .memory(), // Txs and UTXOs related to the wallet will be stored in memory
    );
  }

  Future<(Descriptor receive, Descriptor change)> _getBip84TemplateDescriptors(
    Mnemonic mnemonic,
  ) async {
    const network = // 3. Use the Regtest network
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
