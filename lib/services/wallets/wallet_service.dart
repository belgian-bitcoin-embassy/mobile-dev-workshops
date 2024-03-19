import 'dart:async';

import 'package:mobile_dev_workshops/entities/transaction_entity.dart';
import 'package:mobile_dev_workshops/enums/wallet_type.dart';

abstract class WalletService {
  WalletType get walletType;
  Future<void> init();
  Future<void> addWallet();
  bool get hasWallet;
  Future<void> deleteWallet();
  Future<void> sync();
  Future<int> getSpendableBalanceSat();
  Future<(String? bitcoinInvoice, String? lightningInvoice)> generateInvoices({
    int? amountSat,
    int expirySecs,
    String description,
  });
  Future<List<TransactionEntity>> getTransactions();
  Future<String> pay(
    String invoice, {
    int? amountSat,
    double? satPerVbyte,
    int? absoluteFeeSat,
  });
}

class NoWalletException implements Exception {
  final String message;

  NoWalletException(this.message);
}
