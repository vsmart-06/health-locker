import 'package:flutter/material.dart';
import 'package:src/pages/doctor_home.dart';
import 'package:src/pages/login_page.dart';
import 'package:src/pages/request_page.dart';
import 'package:src/pages/signup_page.dart';
import "package:src/pages/patient_home.dart";
import "package:src/pages/upload_page.dart";
import 'package:src/widgets/record_template.dart';
import "dart:html";

void main() {
  window.document.onContextMenu.listen((evt) => evt.preventDefault());
  runApp(MaterialApp(
    routes: {
      "/": (context) => Login(),
      "/signup": (context) => Signup(),
      "/home/patient": (context) => PatientHome(),
      "/home/doctor": (context) => DoctorHome(),
      "/diagnostics": (context) => RecordsTemplate(title: "Diagnostic Reports"),
      "/discharge": (context) => RecordsTemplate(title: "Discharge Summaries"),
      "/health": (context) => RecordsTemplate(title: "Health Documents"),
      "/immunization": (context) => RecordsTemplate(title: "Immunization Records"),
      "/op-consult": (context) => RecordsTemplate(title: "OP Consult Records"),
      "/prescriptions": (context) => RecordsTemplate(title: "Prescriptions"),
      "/wellness": (context) => RecordsTemplate(title: "Wellness Records"),
      "/invoices": (context) => RecordsTemplate(title: "Invoices"),
      "/upload": (context) => UploadPage(),
      "/request-data": (context) => RequestPage()
    },
    theme: ThemeData(useMaterial3: false),
  ));
}
