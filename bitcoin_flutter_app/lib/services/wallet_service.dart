import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:bitcoin_flutter_app/repositories/mnemonic_repository.dart';

abstract class WalletService {
  Future<void> addWallet();
  Future<void> deleteWallet();
  //Future<double> availableBalance();
}

class BitcoinWalletService implements WalletService {
  final MnemonicRepository _mnemonicRepository;

  BitcoinWalletService({required MnemonicRepository mnemonicRepository})
      : _mnemonicRepository = mnemonicRepository;

  @override
  Future<void> addWallet() async {
    final mnemonic = await Mnemonic.create(WordCount.Words12);
    await _mnemonicRepository.setMnemonic(mnemonic.asString());
    print('Wallet added with mnemonic: ${mnemonic.asString()}');
  }

  @override
  Future<void> deleteWallet() async {
    await _mnemonicRepository.deleteMnemonic();
  }

  /*@override
  Future<double> availableBalance() async {
    final mnemonic = await _mnemonicRepository.getMnemonic();
    if (mnemonic == null || mnemonic.isEmpty) {
      throw NoWalletException('Mnemonic not found');
    }

    return 0.0;
  }*/
}

class NoWalletException implements Exception {
  final String message;

  NoWalletException(this.message);
}
