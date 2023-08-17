import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';
import 'package:memoapp/Screens/Transactions/create_transaction.dart';
import 'package:memoapp/Screens/Transactions/transaction_details.dart';
import 'package:memoapp/Screens/Transactions/trn_model.dart';

import '../../Methods/dropdown.dart';
import '../../sqlite.dart';


class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  final searchCtrl = TextEditingController();
  String keyword = "";

  late DatabaseHelper handler;
  late Future<List<TransactionModel>> transactions;
  final db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    transactions = handler.getTransactions();
    handler.initDB().whenComplete(() async {
      setState(() {
        transactions = getTrn();
      });
    });
    _onRefresh();
  }


  //Method to get data from database
  Future<List<TransactionModel>> getTrn() async {
    return await handler.getTransactions();
  }

  //Method to refresh data on pulling the list
  Future<void> _onRefresh() async {
    setState(() {
      transactions = getTrn();
    });
  }


  var filterTitle = [
    "all",
    "paid",
    "received",
    "power",
    "rent"
  ];
  var filterData = [
    "%",
    "paid",
    "received",
    "power",
    "rent"
  ];
  int currentFilterIndex = 0;
  var trnTypeValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>const CreateTransaction()));
        },
      ),
      body:  SafeArea(
        child: Column(
          children: [

            //Search TextField
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 3),
                    decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(.1),
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: TextFormField(
                      controller: searchCtrl,
                      onChanged: (value){
                        setState(() {
                          keyword = searchCtrl.text;
                          transactions = db.transactionSearch(keyword);
                        });
                      },
                      decoration: InputDecoration(
                          hintText: Locales.string(context,"search"),
                          icon: const Icon(Icons.search),
                          border: InputBorder.none
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 52,
                    margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 3),
                    decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(.1),
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child:  CustDropDown(
                      maxListHeight: 200,
                      icon: Icons.filter_alt_rounded,
                      items: const [
                        CustDropdownMenuItem(
                          value: 0,
                          child: LocaleText("all"),
                        ),
                        CustDropdownMenuItem(
                          value: 1,
                          child: LocaleText("paid"),
                        ),
                        CustDropdownMenuItem(
                          value: 2,
                          child: LocaleText("received"),
                        ),
                        CustDropdownMenuItem(
                          value: 3,
                          child: LocaleText("power"),
                        ),
                        CustDropdownMenuItem(
                          value: 4,
                          child: LocaleText("rent"),
                        ),
                      ],
                      hintText: Locales.string(context, "category"),
                      borderRadius: 5,
                      onChanged: (val) {
                        setState(() {
                          trnTypeValue = val;
                          currentFilterIndex = val;
                          transactions = db.filterTransactions(filterData[currentFilterIndex]);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: FutureBuilder<List<TransactionModel>>(
                future: transactions,
                builder: (BuildContext context, AsyncSnapshot<List<TransactionModel>> snapshot) {
                  //in case whether data is pending
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      //To show a circular progress indicator
                      child: CircularProgressIndicator(),
                    );
                    //If snapshot has error
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/Photos/empty.png",width: 250),
                            MaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              minWidth: 160,
                              color: Theme.of(context).colorScheme.inversePrimary,
                              onPressed: () => _onRefresh(),
                              child: const LocaleText("refresh"),
                            )
                          ],
                        ));
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    //a final variable (item) to hold the snapshot data
                    final items = snapshot.data ?? <TransactionModel>[];
                    return Scrollbar(
                      //The refresh indicator
                      child: RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (BuildContext context, int index) {
                            final dt = DateTime.parse(items[index].createdAt.toString());
                            final noteDate = DateFormat('yyyy-MM-dd (HH:mm a)').format(dt);
                            //Dismissible widget is to delete a data on pushing a record from left to right
                            return Dismissible(
                              direction: DismissDirection.startToEnd,
                              background: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.shade900,
                                ),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    LocaleText(
                                      "delete",
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                              key: ValueKey<int>(items[index].trnId!),
                              onDismissed: (DismissDirection direction) async {
                                await handler
                                    .deleteNote(items[index].trnCategory.toString())
                                    .whenComplete(() => ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(milliseconds: 900),
                                    content: const LocaleText(
                                      "deletemsg",
                                      style: TextStyle(color: Colors.black),
                                    ))));
                                setState(() {
                                  items.remove(items[index]);
                                  _onRefresh();
                                });
                              },
                              child: InkWell(
                                onTap: () {
                                  //To hold the data in text fields for update method
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TransactionDetails(
                                            trnDetails: items[index],
                                          )));
                                },
                                child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    padding: const EdgeInsets.all(8),
                                    width: MediaQuery.of(context).size.width / 2,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.deepPurple.withOpacity(.6),
                                        boxShadow: const [
                                          BoxShadow(blurRadius: 1, color: Colors.grey)
                                        ]),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          title: Text(
                                            items[index].person.toString()??"",
                                            style: const TextStyle(
                                                color: Colors.white, fontSize: 20),
                                          ),
                                          trailing: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8)
                                            ),
                                            child: LocaleText(
                                              items[index].trnCategory??"",
                                              style: const TextStyle(
                                                  color: Colors.deepPurple, fontSize: 14),
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 6,vertical: 0),
                                          dense: true,
                                          visualDensity: const VisualDensity(vertical: -4),
                                          onTap: (){
                                            print("Helloo ${items[index].person.toString()}" );
                                          },
                                        ),
                                        Flexible(
                                            child: Container(
                                                padding:
                                                const EdgeInsets.only(right: 13.0),
                                                child: Text(
                                                  items[index].trnDescription,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                  overflow: TextOverflow.ellipsis,
                                                ))),
                                        Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text(noteDate,
                                                    style: const TextStyle(
                                                        color: Colors.white)),
                                              ],
                                            )),
                                      ],
                                    )),
                              ),
                            );
                          },
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: (5 / 3),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
