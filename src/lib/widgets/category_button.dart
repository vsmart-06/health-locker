// ignore_for_file: must_be_immutable

import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class CategoryButton extends StatefulWidget {
  String? displayText;
  String? redirectUrl;
  CategoryButton(
      {super.key, required this.displayText, required this.redirectUrl});

  @override
  State<CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, widget.redirectUrl!);
        },
        child: Text(
          widget.displayText!,
          style: TextStyle(
              fontFamily: GoogleFonts.redHatDisplay().fontFamily, fontSize: 30),
          textAlign: TextAlign.center,
        ),
        style: ButtonStyle(
            fixedSize: WidgetStateProperty.all(Size(
                MediaQuery.of(context).size.width * 0.2,
                MediaQuery.of(context).size.height * 0.4)),
            side: WidgetStateProperty.all(BorderSide()),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)))),
      ),
    );
  }
}
