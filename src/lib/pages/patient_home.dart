import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:loading_animation_widget/loading_animation_widget.dart";
import "package:src/services/secure_storage.dart";
import "package:src/widgets/file_button.dart";
import "package:src/widgets/logout_button.dart";

class PatientHome extends StatefulWidget {
  const PatientHome({super.key});

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> with SingleTickerProviderStateMixin {
  late int user_id;
  bool login = false;

  String? primaryFont = GoogleFonts.redHatDisplay().fontFamily;
  late TabController controller;

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
    controller = TabController(length: 2, vsync: this);
    controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    if (!login) return LoadingAnimationWidget.inkDrop(color: Colors.blue, size: 100);
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Home", style: TextStyle(fontFamily: primaryFont)),
        centerTitle: true,
        actions: [LogoutButton()],
        bottom: TabBar(
          controller: controller,
          tabs: [
            Tab(text: "Records"),
            Tab(text: "Requests")
          ],
          labelStyle: TextStyle(fontFamily: primaryFont),
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FileButton(
                        displayText: "Diagnostic Reports",
                        redirectUrl: "/diagnostics"),
                    FileButton(
                        displayText: "Discharge Summaries",
                        redirectUrl: "/discharge"),
                    FileButton(
                        displayText: "Health Documents", redirectUrl: "/health"),
                    FileButton(
                        displayText: "Immunization Records",
                        redirectUrl: "/immunization"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FileButton(
                        displayText: "OP Consult Records",
                        redirectUrl: "/op-consult"),
                    FileButton(
                        displayText: "Prescriptions",
                        redirectUrl: "/prescriptions"),
                    FileButton(
                        displayText: "Wellness Records", redirectUrl: "/wellness"),
                    FileButton(displayText: "Invoices", redirectUrl: "/invoices"),
                  ],
                ),
              ],
            ),
          ),
          Container()
        ],
      ),
      floatingActionButton: (controller.index == 0) ? FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, "/upload");
          },
          child: Icon(Icons.add)) : null,
    );
  }
}
