import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:near_api_flutter/near_api_flutter.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/request.dart';
import '../providers/borrow_request_page_provider.dart';
import '../widgets/centered_progress_indicator.dart';

class BorrowRequestPage extends StatefulWidget {
  final KeyPair keyPair;
  final String userAccountId;

  const BorrowRequestPage(
      {Key? key, required this.keyPair, required this.userAccountId})
      : super(key: key);

  @override
  State<BorrowRequestPage> createState() => _BorrowRequestPageState();
}

class _BorrowRequestPageState extends State<BorrowRequestPage>
    with WidgetsBindingObserver {
  late BorrowRequestPageProvider provider;
  final borrowAmountController = TextEditingController();
  final descController = TextEditingController();
  final accountIdController = TextEditingController();
  DateTime now = DateTime.now();
  late DateTime paybackDate = DateTime(now.year, now.month, now.day);
  bool isPersonal = false;
  bool invalidAccountId = true;
  bool isCreateButtonDisabled = true;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<BorrowRequestPageProvider>(context);

    switch (provider.state) {
      case BorrowRequestPageState.init:
        return buildCoinflipPage();
      case BorrowRequestPageState.loading:
        return const CenteredCircularProgressIndicator();
      case BorrowRequestPageState.loaded:
        showTransactionMessage(context);
        return buildCoinflipPage();
      default:
        return buildCoinflipPage();
    }
  }

  buildCoinflipPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
            children: [
              const Text(
                "Borrow Money",
                style: Constants.HEADING_1,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: borrowAmountController,
                      onChanged: (value) {
                        changeCreateButtonState();
                      },
                      decoration: const InputDecoration(
                          labelText: "Borrow Amount", alignLabelWithHint: true),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,5}'))
                      ],
                    ),
                  ),
                  const Text(
                    "  Ⓝ",
                    style: Constants.HEADING_1,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: descController,
                onChanged: (value) {
                  changeCreateButtonState();
                },
                decoration: const InputDecoration(
                    labelText: "Description", alignLabelWithHint: true),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => selectDate(context),
                    child: const Text('Set Payback Date'),
                  ),
                  Text("${paybackDate.toLocal()}".split(' ')[0]),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              CheckboxListTile(
                title: const Text(
                  "From a specific person?",
                ),
                visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity),
                value: isPersonal,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      isPersonal = value;
                    });
                    changeCreateButtonState();
                  }
                },
              ),
              buildAccountIdTextField(),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.deepOrange),
                          onPressed: isCreateButtonDisabled
                              ? null
                              : () {
                                  Request request = Request(
                                      amount: nearToYocto(
                                          borrowAmountController.text),
                                      desc: descController.text,
                                      borrower: widget.userAccountId,
                                      lender: isPersonal
                                          ? accountIdController.text
                                          : '',
                                      paybackTimestamp: BigInt.parse(paybackDate
                                              .microsecondsSinceEpoch
                                              .toString()) *
                                          BigInt.from(1000));
                                  provider.createRequest(widget.keyPair,
                                      widget.userAccountId, request);
                                },
                          child: const Text("Request to borrow")))
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }

  buildAccountIdTextField() {
    return Column(
      children: [
        isPersonal
            ? Column(
                children: [
                  TextField(
                    controller: accountIdController,
                    onChanged: (value) {
                      checkNearAccountId(value);
                      changeCreateButtonState();
                    },
                    decoration: const InputDecoration(
                        labelText: "Account ID", alignLabelWithHint: true),
                  ),
                  invalidAccountId
                      ? Card(
                          color: Colors.amberAccent,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              accountIdController.text == widget.userAccountId
                                  ? "You cannot request to borrow from yourself!"
                                  : "Invalid near account ID (e.g. nearflutter.testnet)",
                              style: const TextStyle(color: Colors.blueGrey),
                            ),
                          ),
                        )
                      : Container(),
                ],
              )
            : Container(),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    borrowAmountController.dispose();
    descController.dispose();
    accountIdController.dispose();
    super.dispose();
  }

  checkNearAccountId(accountId) {
    RegExp regExp = RegExp(
      r"^\w+(?:\.\w+)*\.testnet$",
      caseSensitive: true,
      multiLine: false,
    );
    setState(() {
      if (regExp.allMatches(accountId).isNotEmpty &&
          accountId != widget.userAccountId) {
        invalidAccountId = false;
      } else {
        invalidAccountId = true;
      }
    });
  }

  BigInt nearToYocto(String amount) {
    num nanoNear = double.parse(borrowAmountController.text) * pow(10, 9);
    return BigInt.from(nanoNear) * BigInt.parse('1000000000000000');
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: paybackDate,
        firstDate: DateTime(now.year, now.month, now.day + 1),
        lastDate: DateTime(now.year + 2, now.month, now.day));
    if (picked != null && picked != paybackDate) {
      setState(() {
        paybackDate = picked;
      });
    }
  }

  showTransactionMessage(BuildContext context) async {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 3),
      content: Text(provider.transactionMessage),
      action: SnackBarAction(
        label: 'Hide',
        onPressed: () {
          setState(() {
            provider.transactionMessage = '';
          });
        },
      ),
    );
    if (provider.transactionMessage.isNotEmpty) {
      await Future.delayed(const Duration(seconds: 1), (() {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }));
      resetState();
      provider.transactionMessage = '';
    }
  }

  resetState() {
    setState(() {
      if (provider.transactionMessage == Constants.REQUEST_CREATED_MSG) {
        borrowAmountController.text = '';
        descController.text = '';
        accountIdController.text = '';
        isPersonal = false;
        isCreateButtonDisabled = true;
        paybackDate = DateTime(now.year, now.month, now.day + 1);
      }
      provider.transactionMessage = '';
    });
  }

  void changeCreateButtonState() {
    setState(() {
      if (isPersonal) {
        if (borrowAmountController.text.isNotEmpty &&
            descController.text.isNotEmpty &&
            accountIdController.text.isNotEmpty &&
            !invalidAccountId) {
          isCreateButtonDisabled = false;
        } else {
          isCreateButtonDisabled = true;
        }
      } else {
        if (borrowAmountController.text.isNotEmpty &&
            descController.text.isNotEmpty) {
          isCreateButtonDisabled = false;
        } else {
          isCreateButtonDisabled = true;
        }
      }
    });
  }
}
