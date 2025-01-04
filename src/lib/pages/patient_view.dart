import "dart:convert";

import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:loading_animation_widget/loading_animation_widget.dart";
import "package:src/services/secure_storage.dart";
import "package:src/widgets/category_button.dart";
import "package:src/widgets/logout_button.dart";

class PatientView extends StatefulWidget {
  const PatientView({super.key});

  @override
  State<PatientView> createState() => _PatientViewState();
}

class _PatientViewState extends State<PatientView> {
  late int user_id;
  late String role;
  late String email;
  bool login = false;

  late Map<String, String> categories;

  String? primaryFont = GoogleFonts.redHatDisplay().fontFamily;

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
      String? r = await SecureStorage.read("role");
      String? c = await SecureStorage.read("patient_categories");
      String? e = await SecureStorage.read("patient_email");

      List<String> typeList = [
        "Choose a data type",
        "Diagnostic Reports",
        "Discharge Summaries",
        "Health Documents",
        "Immunization Records",
        "OP Consult Records",
        "Prescriptions",
        "Wellness Records",
        "Invoices"
      ];
      List cats = jsonDecode(c!);
      cats.sort((a, b) => typeList.indexOf(a) - typeList.indexOf(b));

      Map<String, String> y = {};
      for (String x in cats) {
        switch (x) {
          case ("Diagnostic Reports"): y[x] = "/diagnostics"; break;
          case ("Discharge Summaries"): y[x] = "/discharge"; break;
          case ("Health Documents"): y[x] = "/health"; break;
          case ("Immunization Records"): y[x] = "/immunization"; break;
          case ("OP Consult Records"): y[x] = "/op-consult"; break;
          case ("Prescriptions"): y[x] = "/prescriptions"; break;
          case ("Wellness Records"): y[x] = "/wellness"; break;
          case ("Invoices"): y[x] = "/invoices"; break;
        }
      }

      setState(() {
        user_id = int.parse(num!);
        role = r!;
        login = true;
        categories = y;
        email = e!;
      });

    } else {
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
    if (!login)
      return LoadingAnimationWidget.inkDrop(color: Colors.blue, size: 100);
    return Scaffold(
      appBar: AppBar(
        title: Text(email, style: TextStyle(fontFamily: primaryFont)),
        centerTitle: true,
        actions: [LogoutButton()],
      ),
      body: GridView.count(
        crossAxisCount: 4,
        childAspectRatio: (MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height * 2)),
        children: categories.keys.map((value) => CategoryButton(displayText: value, redirectUrl: categories[value])).toList(),
      ),
      floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, "/upload");
              },
              child: Icon(Icons.add)),
    );
  }
}