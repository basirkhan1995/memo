import 'package:flutter/material.dart';
import 'package:memoapp/Screens/Transactions/trn_model.dart';

class TransactionDetails extends StatefulWidget {
  final TransactionModel trnDetails;
  const TransactionDetails({super.key, required this.trnDetails});

  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trnDetails.trnCategory),
      ),

      body: Column(
        children: [
          //Text(widget.trnDetails.person!)
        ],
      ),
    );
  }
}
