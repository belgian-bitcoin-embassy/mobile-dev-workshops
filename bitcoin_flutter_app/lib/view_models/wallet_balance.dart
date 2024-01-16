import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class WalletBalance extends Equatable {
  const WalletBalance({
    required this.walletName,
    required this.balanceSat,
  });

  //final WalletType walletType;
  final String walletName;
  final int balanceSat;

  double get balanceBtc => balanceSat / 100000000;

  @override
  List<Object> get props => [
        walletName,
        balanceSat,
      ];
}
