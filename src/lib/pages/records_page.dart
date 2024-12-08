import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:src/widgets/file_button.dart";
import "package:src/widgets/logout_button.dart";

class Records extends StatefulWidget {
  const Records({super.key});

  @override
  State<Records> createState() => _RecordsState();
}

class _RecordsState extends State<Records> {
  String? primaryFont = GoogleFonts.redHatDisplay().fontFamily;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Scan and Upload",
          style: TextStyle(fontFamily: primaryFont)
        ),
        centerTitle: true,
        actions: [LogoutButton()],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FileButton(displayText: "Diagnostic Reports", redirectUrl: "/diagnostics"),
                FileButton(displayText: "Discharge Summaries", redirectUrl: "/discharge"),
                FileButton(displayText: "Health Documents", redirectUrl: "/health"),
                FileButton(displayText: "Immunization Records", redirectUrl: "/immunization"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FileButton(displayText: "OP Consult Records", redirectUrl: "/op-consult"),
                FileButton(displayText: "Prescriptions", redirectUrl: "/prescriptions"),
                FileButton(displayText: "Wellness Records", redirectUrl: "/wellness"),
                FileButton(displayText: "Invoices", redirectUrl: "/invoices"),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {Navigator.pushNamed(context, "/upload");}, child: Icon(Icons.add)),
    );
  }
}