// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

class Constants {
  static const String PRIVATE_KEY_STRING = "PRIVATE_KEY_STRING";
  static const String PUBLIC_KEY_STRING = "PUBLIC_KEY_STRING";
  static const String USER_ACCOUNT_ID = "USER_ACCOUNT_ID";

  static const String WALLET_LOGIN_URL =
      'https://wallet.testnet.near.org/login/?';
  static const String WALLET_SIGN_URL =
      'https://wallet.testnet.near.org/sign/?';
  static const String CONTRACT_ID = 'lendme.testnet';
  static const String WEB_SUCCESS_URL =
      'https://near-transaction-serializer.herokuapp.com/success';
  static const String WEB_FAILURE_URL =
      'https://near-transaction-serializer.herokuapp.com/failure';
  static const APP_TITLE = 'Lend Me';
  static const DEFAULT_GAS_FEES = 30000000000000;

  static const REQUEST_CREATED_MSG = "Request created successfully!";

  static const HEADING_1 = TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      wordSpacing: -1.5,
      height: 1);

  static const SUBTITL_1 = TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.normal, wordSpacing: 1.25);
}
