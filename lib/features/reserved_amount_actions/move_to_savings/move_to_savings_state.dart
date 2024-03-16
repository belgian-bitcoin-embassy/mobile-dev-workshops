import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class MoveToSavingsState extends Equatable {
  const MoveToSavingsState({
    this.address,
    this.amountSat,
    this.isMovingToSavings = false,
    this.txId,
    this.error,
  });

  final String? address;
  final int? amountSat;
  final bool isMovingToSavings;
  final String? txId;
  final Exception? error;

  MoveToSavingsState copyWith({
    String? address,
    int? amountSat,
    bool? clearAmountSat,
    bool? isMovingToSavings,
    String? txId,
    Exception? error,
    bool? clearError,
  }) {
    return MoveToSavingsState(
      address: address ?? this.address,
      amountSat: clearAmountSat == true ? null : amountSat ?? this.amountSat,
      isMovingToSavings: isMovingToSavings ?? this.isMovingToSavings,
      txId: txId ?? this.txId,
      error: clearError == true ? null : error ?? this.error,
    );
  }

  String? get partialTxId =>
      '${txId?.substring(0, 8)}...${txId?.substring(txId!.length - 8)}';

  @override
  List<Object?> get props => [
        address,
        amountSat,
        isMovingToSavings,
        txId,
        error,
      ];
}
