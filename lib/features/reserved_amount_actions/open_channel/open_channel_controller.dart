import 'package:mobile_dev_workshops/features/reserved_amount_actions/open_channel/open_channel_state.dart';
import 'package:mobile_dev_workshops/services/wallets/impl/lightning_wallet_service.dart';

class OpenChannelController {
  final OpenChannelState Function() _getState;
  final Function(OpenChannelState state) _updateState;
  final LightningWalletService _walletService;

  OpenChannelController({
    required getState,
    required updateState,
    required walletService,
  })  : _getState = getState,
        _updateState = updateState,
        _walletService = walletService;

  void amountChangeHandler(String? amount) async {
    final state = _getState();
    try {
      if (amount == null || amount.isEmpty) {
        _updateState(
            state.copyWith(clearChannelAmountSat: true, clearError: true));
      } else {
        final amountSat = int.parse(amount);

        if (amountSat > await _walletService.spendableOnChainBalanceSat) {
          _updateState(state.copyWith(
            error: NotEnoughFundsException(),
          ));
        } else {
          _updateState(
              state.copyWith(channelAmountSat: amountSat, clearError: true));
        }
      }
    } catch (e) {
      print(e);
      _updateState(state.copyWith(
        error: InvalidAmountException(),
      ));
    }
  }

  Future<void> confirm() async {
    final state = _getState();
    _updateState(state.copyWith(isOpeningChannel: true));
    try {
      final channelId = await _walletService.openChannel(
        host: state.host!,
        port: state.port!,
        nodeId: state.nodeId!,
        channelAmountSat: state.channelAmountSat!,
        announceChannel: state.announceChannel!,
      );
      _updateState(state.copyWith(
        channelId: channelId,
        isOpeningChannel: false,
      ));
    } catch (e) {
      print(e);
      _updateState(state.copyWith(
        error: FailedToOpenChannelError(e.toString()),
        isOpeningChannel: false,
      ));
    }
  }
}

class NoAmountError implements Exception {
  const NoAmountError(this.message);

  final String message;
}

class FailedToOpenChannelError implements Exception {
  const FailedToOpenChannelError(this.message);

  final String message;
}

class NotEnoughFundsException implements Exception {}

class InvalidAmountException implements Exception {}
