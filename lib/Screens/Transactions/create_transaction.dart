import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';
import 'package:memoapp/Screens/Models/category_model.dart';
import 'package:memoapp/Screens/Transactions/person_model.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../../Methods/textfield.dart';
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
  final personCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();

  int selectedPerson = 0;
  String selectedPersonName = "";
  String selectedCategory = "";
  String initMessage = "select_person";

  var trnTypeValue = 0;

  late DatabaseHelper handler;
  late Future<List<PersonModel>> persons;
  late Future<List<CategoryModel>> category;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    persons = handler.getPersonsByID(selectedPerson);
    category = handler.getCategoryById(selectedCategory);
    handler.initDB().whenComplete(() async {
      setState(() {
        persons = getList();
        category = getCategory();
      });
    });
  }

  //Method to get data from database
  Future<List<PersonModel>> getList() async {
    return await handler.getPersons();
  }

  //Method to get data from database
  Future<List<CategoryModel>> getCategory() async {
    return await handler.getCategories();
  }

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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //Header, Date and Category selection

                   ListTile(
                      title: Text(
                        gregorianDate,
                        style: const TextStyle(fontSize: 15),
                      ),
                      subtitle: Text(shamsiDate()),
                    ),


                  //Person selection
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 40,
                            decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(.3),
                                borderRadius: BorderRadius.circular(10)),
                            child:
                            DropdownSearch<PersonModel>(
                              asyncItems: (value) => db.getPersonsByID(value),
                              itemAsString: (PersonModel u) => u.pName.toString(),
                              onChanged: (PersonModel? data) {
                                setState(() {
                                  selectedPerson = data!.pId!.toInt();
                                  selectedPersonName = data.pName;
                                });
                              },
                              dropdownButtonProps: DropdownButtonProps(
                                icon: const Icon(Icons.add,size: 22),
                                onPressed: (){
                                 showModalBottomSheet(
                                     isScrollControlled: true,
                                     context: context, builder: (context){
                                   return Padding(
                                     padding: MediaQuery.of(context).viewInsets,
                                     child: SizedBox(
                                       height: 200,
                                       width: double.maxFinite,
                                       child: Column(
                                         children: [
                                           Container(
                                             margin:const EdgeInsets.symmetric(vertical: 10),
                                             height: 5,
                                             width: 60,
                                             decoration: BoxDecoration(
                                               color: Colors.grey,
                                               borderRadius: BorderRadius.circular(8)
                                             ),
                                           ),

                                           UnderlineInputField(
                                             hint: "person_name",
                                             controller: personCtrl,
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
                                                       db.createPerson(PersonModel(pName: personCtrl.text)).whenComplete(() => Navigator.pop(context));
                                                     }
                                                   },
                                                   child: const LocaleText("create")),
                                             ],
                                           )

                                         ],
                                       ),
                                     ),
                                   );
                                 });
                                }
                              ),
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                    icon: const Icon(Icons.person),
                                    hintText: Locales.string(context, "select_person"),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 0,vertical: 4),
                                    border: InputBorder.none),
                              ),
                            ),
                          ),
                        ),
                      ),

                      //Category
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 40,
                            decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(.3),
                                borderRadius: BorderRadius.circular(8)),
                            child:
                            DropdownSearch<CategoryModel>(
                              autoValidateMode: AutovalidateMode.onUserInteraction,
                              asyncItems: (value) => db.getCategoryById(value),
                              itemAsString: (CategoryModel u) => u.cName,
                              onChanged: (CategoryModel? data) {
                                setState(() {
                                  selectedCategory = data!.cName;
                                });
                              },
                              dropdownButtonProps: DropdownButtonProps(
                                  icon: const Icon(Icons.add,size: 22),
                                  onPressed: (){
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        context: context, builder: (context){
                                      return Padding(
                                        padding: MediaQuery.of(context).viewInsets,
                                        child: SizedBox(
                                          height: 200,
                                          width: double.maxFinite,
                                          child: Column(
                                            children: [
                                              Container(
                                                margin:const EdgeInsets.symmetric(vertical: 10),
                                                height: 5,
                                                width: 60,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey,
                                                    borderRadius: BorderRadius.circular(8)
                                                ),
                                              ),

                                              UnderlineInputField(
                                                hint: "category_name",
                                                controller: categoryCtrl,
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
                                                          db.createCategory(CategoryModel(cName: categoryCtrl.text)).whenComplete(() => Navigator.pop(context));
                                                        }
                                                      },
                                                      child: const LocaleText("create")),
                                                ],
                                              )

                                            ],
                                          ),
                                        ),
                                      );
                                    });
                                  }
                              ),
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                    hintText: Locales.string(context, "select_category"),
                                    hintStyle: const TextStyle(fontSize: 15),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 4,vertical: 5),
                                    border: InputBorder.none),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),


                  //TextFields
                  UnderlineInputField(
                    hint: "amount",
                    inputType: TextInputType.number,
                    controller: trnAmount,
                  ),
                  IntrinsicHeight(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 100,
                        maxHeight: 500,
                      ),
                      child: UnderlineInputField(
                        hint: "description",
                        controller: trnDescription,
                        maxChar: 100,
                        max: null,
                        expand: true,
                      ),
                    ),
                  ),

                  //Buttons
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
                              var response = db.createTransaction2(trnDescription.text, selectedCategory, selectedPerson, int.parse(trnAmount.text)).whenComplete(() => Navigator.pop(context));
                              print("New data entry : $response");
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
