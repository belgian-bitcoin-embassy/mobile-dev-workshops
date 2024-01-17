import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class MnemonicRepository {
  Future<void> setMnemonic(String mnemonic);
  Future<String?> getMnemonic();
  Future<void> deleteMnemonic();
}

class SecureStorageMnemonicRepository implements MnemonicRepository {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _mnemonicKey = 'mnemonic';

  @override
  Future<void> setMnemonic(String mnemonic) async {
    await _secureStorage.write(key: _mnemonicKey, value: mnemonic);
  }

  @override
  Future<String?> getMnemonic() {
    return _secureStorage.read(key: _mnemonicKey);
  }

  @override
  Future<void> deleteMnemonic() {
    return _secureStorage.delete(key: _mnemonicKey);
  }
}
