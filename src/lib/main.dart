import 'package:flutter/material.dart';
import "package:scan_and_upload/pages/records_page.dart";
import "package:scan_and_upload/pages/upload_page.dart";
import 'package:scan_and_upload/widgets/record_template.dart';

void main() {
  runApp(
    MaterialApp(
      routes: {
        "/": (context) => Records(),
        "/diagnostics": (context) => RecordsTemplate(title: "Diagnostic Reports"),
        "/discharge": (context) => RecordsTemplate(title: "Discharge Summaries"),
        "/health": (context) => RecordsTemplate(title: "Health Documents"),
        "/immunization": (context) => RecordsTemplate(title: "Immunization Records"),
        "/op-consult": (context) => RecordsTemplate(title: "OP Consult Records"),
        "/prescriptions": (context) => RecordsTemplate(title: "Prescriptions"),
        "/wellness": (context) => RecordsTemplate(title: "Wellness Records"),
        "/invoices": (context) => RecordsTemplate(title: "Invoices"),
        "/upload": (context) => UploadPage(),
      },
      theme: ThemeData(
        useMaterial3: false
      ),
    )
  );
}
