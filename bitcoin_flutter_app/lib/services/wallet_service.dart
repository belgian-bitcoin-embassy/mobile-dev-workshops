import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:bitcoin_flutter_app/repositories/mnemonic_repository.dart';

abstract class WalletService {
  Future<void> addWallet();
  Future<void> deleteWallet();
  Future<int> getSpendableBalanceSat();
}

class BitcoinWalletService implements WalletService {
  final MnemonicRepository _mnemonicRepository;
  Wallet? _wallet;
  late Blockchain _blockchain;

  BitcoinWalletService({required MnemonicRepository mnemonicRepository})
      : _mnemonicRepository = mnemonicRepository;

  Future<void> init() async {
    // 12. Initialize the blockchain by calling the _initBlockchain method

    // 13. Use the mnemonic repository to check if a mnemonic already exists.
    //  If it does, call the _initWallet method with the mnemonic and then call
    //  the sync method so the wallet is up to date.
  }

  @override
  Future<void> addWallet() async {
    // 1. Use BDKs Mnemonic class to generate a new 12-word mnemonic

    // 2. Store the mnemonic in secure local storage using the MnemonicRepository

    // 10. Call the _initWallet method with the generated mnemonic
  }

  @override
  Future<void> deleteWallet() async {
    // 3. Delete the mnemonic from secure local storage using the MnemonicRepository

    _wallet = null;
  }

  @override
  Future<int> getSpendableBalanceSat() async {
    // 14. Call the getBalance method from the Wallet and return the spendable balance
    //  from it
    return 0;
  }

  bool get hasWallet => _wallet != null;

  Future<void> sync() async {
    // 11. Call the sync method on the _wallet field passing the _blockchain field
  }

  Future<void> _initBlockchain() async {
    // 4. Initialize the Blockchain object by creating a new instance of the
    //  Blockchain class and configuring it to use an Electrum server.
    //  For testing purposes, you can use the following Blockstream Electrum
    //  server url: ssl://electrum.blockstream.info:60002
  }

  Future<void> _initWallet(Mnemonic mnemonic) async {
    // 9. Initialze the _wallet field by creating a new instance of the
    //  Wallet class using the receive and change descriptors from the
    //  _getBip84TemplateDescriptors method and an in-memory database.
  }

  Future<void> _getBip84TemplateDescriptors(
    Mnemonic mnemonic,
  ) async {
    // 5. Create a new secret master key for Testnet from the mnemonic using the
    //  DescriptorSecretKey class.

    // 6. Create a Native Segwit (BIP84) descriptor to generate receive (external) addresses

    // 7. Create a Native Segwit (BIP84) descriptor to generate change (internal) addresses

    // 8. Return the receive and change descriptors as a tuple
    //  (also chanege the return type of the method accordingly)
  }
}
