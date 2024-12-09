import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:src/widgets/logout_button.dart";

class DoctorHome extends StatefulWidget {
  const DoctorHome({super.key});

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> with SingleTickerProviderStateMixin {
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
            Tab(text: "Patients"),
            Tab(text: "Requests")
          ],
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: [
          Container(),
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