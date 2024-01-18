import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class ReceiveState extends Equatable {
  const ReceiveState({
    this.amountSat,
    this.label,
    this.message,
    this.bitcoinInvoice,
  });

  final int? amountSat;
  final String? label;
  final String? message;
  final String? bitcoinInvoice;

  String? get bip21Uri {
    if (bitcoinInvoice == null) {
      return null;
    }

    if (amountSat == null && label == null && message == null) {
      return bitcoinInvoice;
    }

    return 'bitcoin:$bitcoinInvoice?'
        '${amountSat != null ? 'amount=$amountSat&' : ''}'
        '${label != null ? 'label=$label&' : ''}'
        '${message != null ? 'message=$message&' : ''}';
  }

  ReceiveState copyWith({
    int? amountSat,
    String? label,
    String? message,
    String? bitcoinInvoice,
  }) {
    return ReceiveState(
      amountSat: amountSat ?? this.amountSat,
      label: label ?? this.label,
      message: message ?? this.message,
      bitcoinInvoice: bitcoinInvoice ?? this.bitcoinInvoice,
    );
  }

  @override
  List<Object?> get props => [bitcoinInvoice];
}
