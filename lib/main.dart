import 'package:mobile_dev_workshops/features/home/home_screen.dart';
import 'package:mobile_dev_workshops/repositories/mnemonic_repository.dart';
import 'package:mobile_dev_workshops/services/wallets/impl/bitcoin_wallet_service.dart';
import 'package:mobile_dev_workshops/services/wallets/impl/lightning_wallet_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Instantiate the wallet services in the main so
  // we can have one service instance of every wallet for the entire app...
  final bitcoinWalletService = BitcoinWalletService(
    mnemonicRepository: SecureStorageMnemonicRepository(),
  );
  final lightningWalletService = LightningWalletService(
    mnemonicRepository: SecureStorageMnemonicRepository(),
  );
  // ...and have it initialized before the app starts.
  await Future.wait([
    bitcoinWalletService.init(),
    lightningWalletService.init(),
  ]);

  runApp(MyApp(
    bitcoinWalletService: bitcoinWalletService,
    lightningWalletService: lightningWalletService,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.bitcoinWalletService,
    required this.lightningWalletService,
    super.key,
  });

  final BitcoinWalletService bitcoinWalletService;
  final LightningWalletService lightningWalletService;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitcoin Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: HomeScreen(
        walletServices: [bitcoinWalletService, lightningWalletService],
      ),
    );
  }
}
