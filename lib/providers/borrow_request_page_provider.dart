import 'package:flutter/material.dart';
import 'package:near_api_flutter/near_api_flutter.dart';
import '../constants.dart';
import '../models/request.dart';
import '../near/near_api_calls.dart';

enum BorrowRequestPageState { init, loading, loaded }

class BorrowRequestPageProvider with ChangeNotifier {
  BorrowRequestPageState state = BorrowRequestPageState.init;
  String transactionMessage = "";

  createRequest(KeyPair keyPair, String userAccountId, Request request) async {
    updateState(BorrowRequestPageState.loading);

    String method = 'postBorrowRequest';
    double deposit = 0.0;
    String args =
        '{"request":{"id":"", "borrower":"", "lender":"${request.lender}", "desc":"${request.desc}", "paybackTimestamp":"${request.paybackTimestamp.toString()}", "amount":"${request.amount.toString()}"}}';
    dynamic response;
    try {
      response = await NEARApi()
          .callFunction(userAccountId, keyPair, deposit, method, args);
    } catch (e) {
      transactionMessage = "RPC Error! Please try again later.";
    }
    if (response.containsKey("error")) {
      transactionMessage = "Something went wrong!";
    } else {
      if (response['result']['status'].containsKey("Failure")) {
        transactionMessage = response['result']['status']["Failure"]
            ["ActionError"]["kind"]["FunctionCallError"]["ExecutionError"];
      } else if (response['result']['status'].containsKey("SuccessValue")) {
        transactionMessage = Constants.REQUEST_CREATED_MSG;
      }
    }
    updateState(BorrowRequestPageState.loaded);
  }

  //update and notify ui state
  void updateState(BorrowRequestPageState state) {
    this.state = state;
    notifyListeners();
  }

  //singleton
  static final BorrowRequestPageProvider _singleton =
      BorrowRequestPageProvider._internal();

  factory BorrowRequestPageProvider() {
    return _singleton;
  }

  BorrowRequestPageProvider._internal();
}
