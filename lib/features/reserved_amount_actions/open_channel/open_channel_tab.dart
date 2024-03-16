import 'dart:io';

import 'package:mobile_dev_workshops/constants.dart';
import 'package:mobile_dev_workshops/features/reserved_amount_actions/open_channel/open_channel_controller.dart';
import 'package:mobile_dev_workshops/features/reserved_amount_actions/open_channel/open_channel_state.dart';
import 'package:mobile_dev_workshops/services/wallets/impl/lightning_wallet_service.dart';
import 'package:flutter/material.dart';

class OpenChannelTab extends StatefulWidget {
  const OpenChannelTab({required this.walletService, super.key});

  final LightningWalletService walletService;

  @override
  OpenChannelTabState createState() => OpenChannelTabState();
}

class OpenChannelTabState extends State<OpenChannelTab> {
  OpenChannelState _state = OpenChannelState(
    host: Platform.isAndroid ? '10.0.2.2' : '127.0.0.1',
    port: 9735,
    nodeId:
        '02042ef4edb2e33de8aaa30af3bcbfe04af73475ee80d524dad3dfc700f58794d6',
    announceChannel: true,
  );
  late OpenChannelController _controller;

  @override
  void initState() {
    super.initState();

    _controller = OpenChannelController(
      getState: () => _state,
      updateState: (OpenChannelState state) => setState(() => _state = state),
      walletService: widget.walletService,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: kSpacingUnit * 2),
        // Host
        ListTile(
          title: const Text('Host & Port'),
          subtitle: Text('${_state.host!}:${_state.port}'),
        ),
        // Node ID
        ListTile(
          title: const Text('Node ID'),
          subtitle: Text(_state.nodeId!),
        ),
        // Channel amount
        const SizedBox(height: kSpacingUnit * 2),
        TextField(
          onChanged: _controller.amountChangeHandler,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Channel amount',
            hintText: '0',
            helperText: 'The amount of sats to make instantly spendable.',
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Error message
        SizedBox(
          height: kSpacingUnit * 2,
          child: Text(
            _state.error is NoAmountError ||
                    _state.error is InvalidAmountException
                ? 'Please enter a valid amount.'
                : _state.error is NotEnoughFundsException
                    ? 'Not enough funds to make spendable.'
                    : _state.error is FailedToOpenChannelError
                        ? 'Failed to make funds instantly spendable. Please try again.'
                        : '',
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        ),
        const SizedBox(height: kSpacingUnit * 2),
        // Send funds Button
        ElevatedButton.icon(
          onPressed: _state.isOpeningChannel
              ? null
              : () => _controller.confirm().then(
                    (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Channel opening successful.'),
                        ),
                      );
                      Navigator.pop(context);
                    },
                  ),
          label: const Text('Make instantly spendable'),
          icon: _state.isOpeningChannel
              ? const CircularProgressIndicator()
              : const Icon(Icons.flash_on),
        ),
      ],
    );
  }
}
