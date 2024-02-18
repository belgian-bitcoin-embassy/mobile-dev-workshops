enum WalletType {
  onChain,
  lightning,
}

extension WalletTypeX on WalletType {
  String get label {
    switch (this) {
      case WalletType.onChain:
        return 'Savings';
      case WalletType.lightning:
        return 'Spending';
    }
  }
}
