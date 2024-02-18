import 'package:bitcoin_flutter_app/view_models/transactions_list_item_view_model.dart';
import 'package:bitcoin_flutter_app/view_models/wallet_balance_view_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class HomeState extends Equatable {
  const HomeState({
    this.walletBalances = const [],
    this.transactionLists = const [],
    this.transactionListIndex = 0,
  });

  final List<WalletBalanceViewModel> walletBalances;
  final List<List<TransactionsListItemViewModel>?> transactionLists;
  final int transactionListIndex;

  HomeState copyWith({
    List<WalletBalanceViewModel>? walletBalances,
    List<List<TransactionsListItemViewModel>?>? transactionLists,
    int? transactionListIndex,
  }) {
    return HomeState(
      walletBalances: walletBalances ?? this.walletBalances,
      transactionLists: transactionLists ?? this.transactionLists,
      transactionListIndex: transactionListIndex ?? this.transactionListIndex,
    );
  }

  @override
  List<Object?> get props => [
        walletBalances,
        transactionLists,
        transactionListIndex,
      ];
}
