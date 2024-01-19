import 'package:bitcoin_flutter_app/view_models/wallet_balance_view_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class HomeState extends Equatable {
  const HomeState({
    this.walletBalance,
  });

  final WalletBalanceViewModel? walletBalance;

  HomeState copyWith({
    WalletBalanceViewModel? walletBalance,
    bool clearWalletBalance = false,
  }) {
    return HomeState(
      walletBalance:
          clearWalletBalance ? null : walletBalance ?? this.walletBalance,
    );
  }

  @override
  List<Object?> get props => [walletBalance];
}
