import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:src/widgets/file_button.dart";
import "package:src/widgets/logout_button.dart";

class PatientHome extends StatefulWidget {
  const PatientHome({super.key});

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> with SingleTickerProviderStateMixin {
  String? primaryFont = GoogleFonts.redHatDisplay().fontFamily;
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Scan and Upload", style: TextStyle(fontFamily: primaryFont)),
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
