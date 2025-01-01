import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:src/services/secure_storage.dart';
import 'package:src/widgets/logout_button.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  bool login = false;
  late int user_id;

  String? primaryFont = GoogleFonts.redHatDisplay().fontFamily;
  ScrollController controller = ScrollController();
  TextEditingController textController = TextEditingController();

  String patient = "";
  List<String> categories = [];
  List<String> typeList = [
    "Diagnostic Reports",
    "Discharge Summaries",
    "Health Documents",
    "Immunization Records",
    "OP Consult Records",
    "Prescriptions",
    "Wellness Records",
    "Invoices"
  ];
  DateTime expiry = DateTime.now();

  bool submitted = false;
  String? error;
  String? message;
  String calendarKey = DateTime.now().toString();

  String baseUrl = "http://127.0.0.1:8000/health_locker";

  Future<bool> checkLogin() async {
    Map<String, String> info = await SecureStorage.read();
    if (info["last_login"] != null) {
      DateTime date = DateTime.parse(info["last_login"]!);
      if (DateTime.now().subtract(Duration(days: 30)).compareTo(date) >= 0) {
        return false;
      }
    }
    return (info["user_id"] != null);
  }

  Future<void> loadUserId() async {
    if (await checkLogin()) {
      String? num = await SecureStorage.read("user_id");
      setState(() {
        user_id = int.parse(num!);
        login = true;
      });
    }
    else {
      await SecureStorage.delete();
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => route == "/");
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  @override
  Widget build(BuildContext context) {
    if (!login) return LoadingAnimationWidget.inkDrop(color: Colors.blue, size: 100);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Request a health record",
          style: TextStyle(fontFamily: primaryFont)
        ),
        centerTitle: true,
        actions: [LogoutButton()],
      ),
      body: SingleChildScrollView(
        controller: controller,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: "Patient",
                  hintText: "Ex: abc@gmail.com",
                  border: OutlineInputBorder(),
                  errorText: (submitted && patient.isEmpty) ? "Patient cannot be empty" : null
                ),
                style: TextStyle(fontFamily: primaryFont),
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    patient = value;
                  });
                },
              ),
            ),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              childAspectRatio: 7,
              children: typeList.map((name) => CheckboxListTile(
                title: Text(name, style: TextStyle(fontFamily: primaryFont)),
                value: categories.contains(name),
                onChanged: (value) {
                  setState(() {
                    (value!) ? categories.add(name) : categories.remove(name);
                  });
                },
              ),).toList()
            ),
            Align(child: Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 10, 10, 10),
              child: Text("Expiry", style: TextStyle(fontFamily: primaryFont, fontSize: 17),),
            ), alignment: Alignment.centerLeft,),
            CalendarDatePicker(
              key: Key(calendarKey),
              initialDate: DateTime.now(),
              firstDate: DateTime.now(), 
              lastDate: DateTime.now().add(Duration(days: 365)), 
              onDateChanged: (value) {
                setState(() {
                  expiry = value;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextButton(
                  style: ButtonStyle(
                      minimumSize: WidgetStatePropertyAll(Size(125, 60)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                      backgroundColor: WidgetStatePropertyAll(Colors.blue),
                      foregroundColor: WidgetStatePropertyAll(Colors.white)),
                  onPressed: () async {
                    if (patient.isEmpty || categories.isEmpty) {
                      setState(() {
                        submitted = true;
                      });
                      return;
                    }
                    var response = await post(Uri.parse(baseUrl + "/add-request/"), body: jsonEncode({"user_id": user_id.toString(), "second_id": patient, "categories": categories, "end_date": expiry.toString()}));
                    var info = jsonDecode(response.body);
                    setState(() {
                      submitted = true;
                      error = (response.statusCode >= 400) ? info["message"] : null;
                      if (response.statusCode == 200) {
                        message = info["message"];
                        textController.clear();
                        patient = "";
                        categories = [];
                        submitted = false;
                        calendarKey = DateTime.now().toString();
                      }
                    });
                  },
                  child: Text("Submit request",
                      style: TextStyle(fontFamily: primaryFont))),
            ),
            (submitted && error != null) ? Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(error!,
                  style: TextStyle(fontFamily: primaryFont, color: Colors.red)),
            )
            : Container(),
            (submitted && categories.isEmpty) ? Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text("You have to choose at least 1 category",
                  style: TextStyle(fontFamily: primaryFont, color: Colors.red)),
            )
            : Container(),
            (message != null) ? Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(message!,
                  style: TextStyle(fontFamily: primaryFont)),
            )
            : Container(),
          ]
        )
      ),
    );
  }
}