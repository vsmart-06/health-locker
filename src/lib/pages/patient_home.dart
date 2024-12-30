import "dart:convert";

import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:http/http.dart";
import "package:loading_animation_widget/loading_animation_widget.dart";
import "package:src/services/secure_storage.dart";
import "package:src/widgets/category_button.dart";
import "package:src/widgets/logout_button.dart";
import "package:src/widgets/request_card.dart";

class PatientHome extends StatefulWidget {
  const PatientHome({super.key});

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome>
    with SingleTickerProviderStateMixin {
  late int user_id;
  late String role;
  bool login = false;

  List requests = [];

  String? primaryFont = GoogleFonts.redHatDisplay().fontFamily;
  late TabController controller;

  String baseUrl = "http://127.0.0.1:8000/health_locker";

  Future<void> getRequests() async {
    var response = await post(Uri.parse(baseUrl + "/fetch-requests/"),
        body: {"user_id": user_id.toString(), "role": role});
    List data = jsonDecode(response.body)["data"];
    setState(() {
      requests = data;
    });
  }

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
      setState(() {
        user_id = int.parse(num!);
        role = r!;
        login = true;
      });
      await getRequests();
    } else {
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
    if (!login)
      return LoadingAnimationWidget.inkDrop(color: Colors.blue, size: 100);
    return Scaffold(
      appBar: AppBar(
        title: Text("Home", style: TextStyle(fontFamily: primaryFont)),
        centerTitle: true,
        actions: [LogoutButton()],
        bottom: TabBar(
          controller: controller,
          tabs: [Tab(text: "Records"), Tab(text: "Requests")],
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
                    CategoryButton(
                        displayText: "Diagnostic Reports",
                        redirectUrl: "/diagnostics"),
                    CategoryButton(
                        displayText: "Discharge Summaries",
                        redirectUrl: "/discharge"),
                    CategoryButton(
                        displayText: "Health Documents",
                        redirectUrl: "/health"),
                    CategoryButton(
                        displayText: "Immunization Records",
                        redirectUrl: "/immunization"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CategoryButton(
                        displayText: "OP Consult Records",
                        redirectUrl: "/op-consult"),
                    CategoryButton(
                        displayText: "Prescriptions",
                        redirectUrl: "/prescriptions"),
                    CategoryButton(
                        displayText: "Wellness Records",
                        redirectUrl: "/wellness"),
                    CategoryButton(
                        displayText: "Invoices", redirectUrl: "/invoices"),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: requests
                .map((request) => DataRequest(
                      request_id: request["request_id"],
                      status: request["status"],
                      categories: request["categories"],
                      other: request["user"],
                      expiration: request["expiry"],
                      role: role,
                      callback: () {
                        setState(() async {
                          await getRequests();
                        });
                      },
                    ))
                .toList(),
          )
        ],
      ),
      floatingActionButton: (controller.index == 0)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, "/upload");
              },
              child: Icon(Icons.add))
          : null,
    );
  }
}
