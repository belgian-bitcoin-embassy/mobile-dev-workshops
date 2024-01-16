import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class WalletBalance extends Equatable {
  const WalletBalance({
    required this.walletName,
  });

  //final WalletType walletType;
  final String walletName;

  @override
  List<Object> get props => [
        walletName,
      ];
}
