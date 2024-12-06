// ignore_for_file: must_be_immutable

import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class FileButton extends StatefulWidget {
  String? displayText;
  String? redirectUrl;
  FileButton({super.key, required this.displayText, required this.redirectUrl});

  @override
  State<FileButton> createState() => _FileButtonState();
}

class _FileButtonState extends State<FileButton> {
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
            fontFamily: GoogleFonts.redHatDisplay().fontFamily,
            fontSize: 30
          ),
          textAlign: TextAlign.center,
        ),
        style: ButtonStyle(
          fixedSize: WidgetStateProperty.all(Size(MediaQuery.of(context).size.width * 0.2, MediaQuery.of(context).size.height * 0.4)),
          side: WidgetStateProperty.all(BorderSide()),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))
        ),
      ),
    );
  }
}