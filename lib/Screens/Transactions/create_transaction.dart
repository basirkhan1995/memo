import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';
import 'package:memoapp/Screens/Transactions/trn_model.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import '../../Methods/dropdown.dart';
import '../../Methods/textfield.dart';
import '../../main.dart';
import '../../sqlite.dart';

class CreateTransaction extends StatefulWidget {
  const CreateTransaction({super.key});

  @override
  State<CreateTransaction> createState() => _CreateTransactionState();
}

class _CreateTransactionState extends State<CreateTransaction> {
  final formKey = GlobalKey<FormState>();
  final db = DatabaseHelper();
  final trnDescription = TextEditingController();
  final trnAmount = TextEditingController();
  var trnTypeValue = 0;

  @override


  Widget build(BuildContext context) {
    final dt = DateTime.now();

    //Gregorian Date format
    final gregorianDate = DateFormat('yyyy-MM-dd (HH:mm a)').format(dt);
    Jalali persianDate = dt.toJalali();

    //Persian Date format
    String shamsiDate() {
      final f = persianDate.formatter;
      return '${f.yyyy}/${f.mm}/${f.dd}';
    }

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(
                            gregorianDate,
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Text(shamsiDate()),
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                width: 150,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(.2),
                                    borderRadius: BorderRadius.circular(10)),
                                child: CustDropDown(
                                  items: const [
                                    CustDropdownMenuItem(
                                      value: 0,
                                      child: LocaleText("paid"),
                                    ),
                                    CustDropdownMenuItem(
                                      value: 1,
                                      child: LocaleText("received"),
                                    ),
                                    CustDropdownMenuItem(
                                      value: 2,
                                      child: LocaleText("debt"),
                                    ),
                                  ],
                                  hintText: Locales.string(context, "category"),
                                  borderRadius: 5,
                                  onChanged: (val) {
                                    setState(() {
                                      trnTypeValue = val;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  UnderlineInputField(
                    hint: "amount",
                    controller: trnAmount,
                  ),
                  IntrinsicHeight(
                    child: ConstrainedBox(
                      constraints:  const BoxConstraints(
                        minHeight: 250,
                        maxHeight: 500,
                      ),
                      child: UnderlineInputField(
                        hint: "description",
                        controller: trnDescription,
                        maxChar: 500,
                        max: null,
                        expand: true,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const LocaleText("cancel")),
                      TextButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              db.createTransaction(TransactionModel(
                                trnDescription: trnDescription.text,
                                amount: trnAmount.text,
                                trnCategory: trnTypeValue == 0?"work": trnTypeValue == 1?"payment":trnTypeValue == 2?"received":trnTypeValue==3?"meeting":"other",
                              ))
                                  .whenComplete(() => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const MyHomePage())));
                            }
                          },
                          child: const LocaleText("create")),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
