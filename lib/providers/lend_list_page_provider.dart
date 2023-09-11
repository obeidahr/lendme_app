import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:near_api_flutter/near_api_flutter.dart';
import '../models/request.dart';
import '../near/near_api_calls.dart';

enum LendListState { loading, loaded }

class LendListProvider with ChangeNotifier {
  LendListState state = LendListState.loading;
  String transactionMessage = "";
  List<Request> requests = [];

  Future<void> loadListData(
      {required KeyPair keyPair,
      required String userAccountId,
      Request? fullfilledRequest}) async 
  {
    String method = 'getUnfulfilledRequests';
    String args = '{}';
    dynamic response;

    if (fullfilledRequest != null) {
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
      if (fullfilledRequest != null) {
        transactionMessage = "Thank you for helping someone in need";
        for (var request in requests) {
          if (request == fullfilledRequest) {
            transactionMessage =
                "Something went wrong!\nplease make sure you follow the wallet and approve the transaction.";
            break;
          }
        }
      }
    } catch (e) {
      transactionMessage = " RPC Error! Please try again later. ";
    }
    updateState(LendListState.loaded);
  }

  lend(
    KeyPair keyPair,
    String userAccountId,
    Request fullfilledRequest,
    double deposit) async 
  {
    String method = 'lend';
    String args = '{"requestId":"${fullfilledRequest.id}"}';
    await NEARApi().callFunction(userAccountId, keyPair, deposit, method, args);
  }

  //update and notify ui state
  void updateState(LendListState state) {
    this.state = state;
    notifyListeners();
  }

  //singleton
  static final LendListProvider _singleton = LendListProvider._internal();

  factory LendListProvider() {
    return _singleton;
  }

  LendListProvider._internal();
}
