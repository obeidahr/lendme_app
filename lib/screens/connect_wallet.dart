import 'package:flutter/material.dart';
import 'package:near_api_flutter/near_api_flutter.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/connect_wallet_provider.dart';
import '../widgets/centered_progress_indicator_with_app_bar.dart';
import 'home_page.dart';

class ConnectWalletScreen extends StatefulWidget {
  const ConnectWalletScreen({Key? key}) : super(key: key);

  @override
  State<ConnectWalletScreen> createState() => _ConnectWalletScreenState();
}

class _ConnectWalletScreenState extends State<ConnectWalletScreen>
    with WidgetsBindingObserver {
  String accountId = "";
  bool invalidAccountId = false;
  bool isConnectWalletDisabled = true;

  late WalletConnectProvider provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<WalletConnectProvider>(context);
    switch (provider.state) {
      case WalletConnectionState.initial:
        provider.checkLoggedInUser();
        return const CenteredCircularProgressIndicatorWithAppBar();
      case WalletConnectionState.loggedIn:
        Future.delayed(const Duration(seconds: 1)).then((_) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => GoodFaithPage(
                    keyPair: provider.keyPair!,
                    userAccountId: provider.userAccountId!,
                  )));
        });
        return const CenteredCircularProgressIndicatorWithAppBar();
      case WalletConnectionState.resetingState:
        provider.resetState();
        return const CenteredCircularProgressIndicatorWithAppBar();
      case WalletConnectionState.loggedOut:
        return buildLoginPage();
      case WalletConnectionState.validatingLogin:
        return const CenteredCircularProgressIndicatorWithAppBar();
      case WalletConnectionState.loginFailed:
        return buildLoginFailedPage();
    }
  }

  buildLoginPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lend Me"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: buildLoginCard(),
      ),
    );
  }

  buildLoginCard() {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Lend Me app helps you borrow and lend => on NEAR"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  accountId = value;
                  checkNearAccountId(accountId);
                });
              },
              decoration: const InputDecoration(
                  labelText: "NEAR account to connect with"),
            ),
          ),
          invalidAccountId
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Invalid near account ID (e.g. nearflutter.testnet)",
                    style: TextStyle(
                        color: Colors.redAccent,
                        backgroundColor: Colors.amberAccent),
                  ),
                )
              : Container(),
          isConnectWalletDisabled
              ? ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(primary: Colors.grey),
                  child: const Text("Connect Wallet"))
              : ElevatedButton(
                  onPressed: () {
                    connectWallet(accountId);
                  },
                  child: const Text("Connect Wallet"))
        ],
      ),
    );
  }

  buildLoginFailedPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lend Me"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            buildLoginCard(),
            const Text(
              "Wallet connection failed, please try again",
              style: TextStyle(
                  color: Colors.redAccent, backgroundColor: Colors.amberAccent),
            )
          ],
        ),
      ),
    );
  }

  connectWallet(accountId) {
    provider.userAccountId = accountId;
    provider.keyPair = KeyStore.newKeyPair();

    //Create NEAR Account object to connect to the wallet with
    Account account = Account(
        accountId: accountId,
        keyPair: provider.keyPair!,
        provider: NEARTestNetRPCProvider());

    //create a wallet object and connect to it
    //this will open the wallet, and when the user navigates back to this screen,
    //the didChangeAppLifecycleState will be called. We go from there.
    var wallet = Wallet(Constants.WALLET_LOGIN_URL);
    wallet.connect(
        Constants.CONTRACT_ID,
        Constants.APP_TITLE,
        Constants.WEB_SUCCESS_URL,
        Constants.WEB_FAILURE_URL,
        account.publicKey);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //detect when app opens back after connecting to the wallet
    switch (state) {
      case AppLifecycleState.resumed:
        if (accountId != "") {
          WalletConnectProvider().checkWalletConnectionResult(
              accountId, provider.keyPair!); //changes ui state to validating
        }
        break;
      default:
        break;
    }
  }

  checkNearAccountId(accountId) {
    RegExp regExp = RegExp(
      r"^\w+(?:\.\w+)*\.testnet$",
      caseSensitive: true,
      multiLine: false,
    );
    if (regExp.allMatches(accountId).isNotEmpty) {
      invalidAccountId = false;
      isConnectWalletDisabled = false;
    } else {
      invalidAccountId = true;
      isConnectWalletDisabled = true;
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
