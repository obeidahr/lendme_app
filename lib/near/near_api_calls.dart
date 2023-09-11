import 'package:near_api_flutter/near_api_flutter.dart';
import '../constants.dart';

class NEARApi {
  callViewFunction(userAccountId, keyPair, method, args) async {
    Account connectedAccount = Account(
        accountId: userAccountId,
        keyPair: keyPair,
        provider: NEARTestNetRPCProvider());

    Contract contract = Contract(Constants.CONTRACT_ID, connectedAccount);
    Map response = await contract.callViewFuntion(method, args);
    return response;
  }

  //mutateState
  callFunction(String userAccountId, KeyPair keyPair, double deposit, String method, String args) async {
    Account connectedAccount = Account(
        accountId: userAccountId,
        keyPair: keyPair,
        provider: NEARTestNetRPCProvider());

    Contract contract = Contract(Constants.CONTRACT_ID, connectedAccount);
    Map response = {};
    if (deposit > 0) {
      var wallet = Wallet(Constants.WALLET_LOGIN_URL);
      response = await contract.callFunctionWithDeposit(
          method,
          args,
          wallet,
          deposit,
          Constants.WEB_SUCCESS_URL,
          Constants.WEB_FAILURE_URL,
          Constants.WALLET_SIGN_URL);
    } else {
      response = await contract.callFunction(method, args, 0.0);
    }
    return response;
  }

  Future<bool> hasAccessKey(accountId, KeyPair keyPair) async {
    Account account = Account(
        accountId: accountId,
        keyPair: keyPair,
        provider: NEARTestNetRPCProvider());
    AccessKey? accessKey = await account.findAccessKey();
    return accessKey.nonce == -1 ? false : true;
  }

  //singleton
  static final NEARApi _singleton = NEARApi._internal();

  factory NEARApi() {
    return _singleton;
  }

  NEARApi._internal();
}
