import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:src/widgets/logout_button.dart";

class DoctorHome extends StatefulWidget {
  const DoctorHome({super.key});

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  String? primaryFont = GoogleFonts.redHatDisplay().fontFamily;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}