import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:near_api_flutter/near_api_flutter.dart';
import '../models/request.dart';
import '../near/near_api_calls.dart';

enum LedgerPageState { loading, loaded }

class LedgerPageProvider with ChangeNotifier {
  LedgerPageState state = LedgerPageState.loading;
  String transactionMessage = "";
  List<Request> requests = [];

  Future<void> loadListData(
      {required KeyPair keyPair,
      required String userAccountId,
      Request? payedbackRequest}) async 
  {
    String method = 'getAccountFulfilledRequests';
    String args = '{"accountId":"$userAccountId"}';
    dynamic response;

    if (payedbackRequest != null) {
      // Delay 1 second to make sure transactions finalized before getting updated data
      await Future.delayed(const Duration(seconds: 1));
    }
    try {
      response = await NEARApi()
          .callViewFunction(userAccountId, keyPair, method, args);
      var result = utf8.decode(response['result']['result'].cast<int>());
      requests = (json.decode(result) as List)
          .map((e) => Request.fromJson(e))
          .toList();
      if (payedbackRequest != null) {
        transactionMessage = "Thank you for keeping your end of the deal";
        for (var request in requests) {
          if (request == payedbackRequest) {
            transactionMessage =
                "Something went wrong!\nplease make sure you follow the wallet and approve the transaction.";
            break;
          }
        }
      }
    } catch (e) {
      transactionMessage = " RPC Error! Please try again later. ";
    }
    updateState(LedgerPageState.loaded);
  }

  payback(
    KeyPair keyPair,
    String userAccountId, 
    Request fullfilledRequest,
    double deposit) async 
  {
    String method = 'payback';
    String args = '{"requestId":"${fullfilledRequest.id}"}';
    await NEARApi().callFunction(userAccountId, keyPair, deposit, method, args);
  }

  //update and notify ui state
  void updateState(LedgerPageState state) {
    this.state = state;
    notifyListeners();
  }

  //singleton
  static final LedgerPageProvider _singleton = LedgerPageProvider._internal();

  factory LedgerPageProvider() {
    return _singleton;
  }

  LedgerPageProvider._internal();
}
