import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../sqlite.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {

  var items = [
    "notes",
    "work",
    "payment",
    "meeting",
    "received"
  ];

  int? totalNotes;
  int? totalWorks;
  int? totalPayments;
  int? totalReceived;
  int? totalMeetings;

  int currentIndex = 0;
  late DatabaseHelper handler;
  final db = DatabaseHelper();
  //Total Users count

  Future<int?> total() async {
    int? count = await handler.totalNotes();
    setState(() => totalNotes = count!);
    return totalNotes;
  }
  Future<int?> totalWork() async {
    int? count = await handler.totalCategory();
    setState(() => totalWorks = count!);
    return totalWorks;
  }

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    total();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const LocaleText("task"),
      ),
      body: GridView.builder(
          itemCount: items.length,
          itemBuilder: (context,index){
        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.deepPurple.withOpacity(.1)
          ),
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LocaleText(items[index],style: const TextStyle(fontSize: 15),),
              //Text(totalWorks.toString())

            ],
          )),
        );
      },
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: (5 / 3),
      ))
    );
  }
}
