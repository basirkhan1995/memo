import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';
import 'package:memoapp/Methods/textfield.dart';
import 'package:memoapp/Screens/Notes/note_model.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../../Methods/dropdown.dart';
import '../../sqlite.dart';

class NoteDetails extends StatefulWidget {
  final Notes? details;
  const NoteDetails({super.key,this.details});

  @override
  State<NoteDetails> createState() => _NoteDetailsState();
}

class _NoteDetailsState extends State<NoteDetails> {
  final db = DatabaseHelper();
  bool isUpdate = false;
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  var dropValue = 0;

  late DatabaseHelper handler;
  late Future<List<Notes>> notes;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    notes = handler.getNotes();
    handler.initDB().whenComplete(() async {
      setState(() {
        notes = getList();
      });
    });
  }



  //Method to get data from database
  Future<List<Notes>> getList() async {
    return await handler.getNotes();
  }

   //Method to refresh data on pulling the list
   Future<void> _onRefresh() async {
    setState(() {
      notes = getList();
    });
  }
  @override
  Widget build(BuildContext context) {

    final dt = DateTime.parse(widget.details!.createdAt.toString());

    //Gregorian Date format
    final gregorianDate = DateFormat('yyyy-MM-dd (HH:mm a)').format(dt);
    Jalali persianDate = dt.toJalali();

    //Persian Date format
    String shamsiDate() {
      final f = persianDate.formatter;
      return '${f.yyyy}/${f.mm}/${f.dd}';
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        actions: [
         isUpdate?Padding(
           padding: const EdgeInsets.all(8.0),
           child: IconButton(
               onPressed: (){
                 setState(() {
                   isUpdate = !isUpdate;
                   db.updateNotes(Notes(noteTitle: titleCtrl.text, noteContent: contentCtrl.text,category: dropValue == 0?"work": dropValue == 1?"payment":dropValue == 2?"received":dropValue==3?"meeting":"other", noteId: widget.details!.noteId));
                 });
               },
               icon: const Icon(Icons.check,size: 18,)),
         ): Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                onPressed: (){
                 setState(() {
                   isUpdate = !isUpdate;
                   titleCtrl.text = widget.details!.noteTitle;
                   contentCtrl.text = widget.details!.noteContent;
                   _onRefresh();
                 });
                },
                icon: const Icon(Icons.edit,size: 18,)),
          ),
        ],
        title: Text(widget.details!.noteTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width *.5,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                        dense: true,
                        title: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.deepPurple.withOpacity(.3)
                            ),
                            child: Text(gregorianDate,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 13),)),
                        subtitle:Text(shamsiDate(),style: const TextStyle(color: Colors.black38,fontWeight: FontWeight.bold,fontSize: 15),),

                      ),
                    ),
                  ],
                ),

                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      isUpdate? Container(
                        padding: const EdgeInsets.all(8),
                        width: 140,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(.2),
                            borderRadius: BorderRadius.circular(10)),
                        child: CustDropDown(
                          defaultSelectedIndex: widget.details?.category == "work"?0:widget.details?.category == "payment"?1:widget.details?.category == "received"?2:widget.details?.category == "meeting"?3:0,
                          items: const [
                            CustDropdownMenuItem(
                              value: 0,
                              child: LocaleText("work"),
                            ),
                            CustDropdownMenuItem(
                              value: 1,
                              child: LocaleText("payment"),
                            ),
                            CustDropdownMenuItem(
                              value: 2,
                              child: LocaleText("received"),
                            ),
                            CustDropdownMenuItem(
                              value: 3,
                              child: LocaleText("meeting"),
                            ),
                          ],
                          hintText: Locales.string(context, "category"),
                          borderRadius: 5,
                          onChanged: (val) {
                            setState(() {
                              dropValue = val;
                            });
                          },
                        ),
                      ): Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.deepPurple.withOpacity(.3)
                          ),
                          child: LocaleText(widget.details!.category??"",style: const TextStyle(fontSize: 17),)),
                    ],
                  ),
                )
              ],
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              visualDensity: const VisualDensity(vertical: -4),
              dense: true,
              title: const LocaleText("title",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
              subtitle: isUpdate? UnderlineInputField(hint: "title",controller: titleCtrl): Text(widget.details!.noteTitle,style: const TextStyle(fontSize: 18,color: Colors.deepPurple,fontWeight: FontWeight.bold),),
              trailing: IconButton(
                icon: Icon(Icons.delete,color: Colors.red.shade900),
                onPressed: (){
                  db.deleteNote(widget.details!.noteId.toString());
                  Navigator.pop(context);
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: ListTile(
                  visualDensity: const VisualDensity(vertical: -4),
                  dense: true,
                  title: const LocaleText("content",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black),),
                  subtitle:isUpdate? UnderlineInputField(hint: "content",controller: contentCtrl):  Text(widget.details!.noteContent,style: const TextStyle(fontSize: 16,color: Colors.black38),),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
