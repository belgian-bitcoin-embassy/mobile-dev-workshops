import 'package:bitcoin_flutter_app/view_models/transactions_list_item_view_model.dart';
import 'package:bitcoin_flutter_app/view_models/wallet_balance_view_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class HomeState extends Equatable {
  const HomeState({
    this.walletBalance,
    this.transactions = const [],
  });

  final WalletBalanceViewModel? walletBalance;
  final List<TransactionsListItemViewModel> transactions;

  HomeState copyWith({
    WalletBalanceViewModel? walletBalance,
    bool clearWalletBalance = false,
    List<TransactionsListItemViewModel>? transactions,
  }) {
    return HomeState(
      walletBalance:
          clearWalletBalance ? null : walletBalance ?? this.walletBalance,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  List<Object?> get props => [walletBalance, transactions];
}
