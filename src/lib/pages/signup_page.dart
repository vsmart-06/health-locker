import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:http/http.dart";
import "package:src/services/secure_storage.dart";
import "dart:core";
import "dart:convert";

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String email = "";
  String password = "";
  String? role;
  String? errorText;
  List<bool> errors = [false, false];
  String? primaryFont = GoogleFonts.redHatDisplay().fontFamily;


  String baseUrl = "http://127.0.0.1:8000/health_locker";

  bool validateInputs() {
    setState(() {
      errors = [
        !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
            .hasMatch(email),
        !RegExp(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^a-zA-Z0-9]).{8,}")
            .hasMatch(password)
      ];
    });
    return (!errors[0] && !errors[1]);
  }

  void signup() async {
    var response = await post(Uri.parse(baseUrl + "/signup/"),
        body: {"email": email, "password": password, "role": role});

    var info = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await SecureStorage.writeMany({"user_id": info["user_id"].toString(), "role": info["role"], "last_login": DateTime.now().toString()});
      await Navigator.popAndPushNamed(context, "/home");
      return;

    } else if (response.statusCode == 409) {
      setState(() {
        errorText = info["error"];
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Sign Up",
            style: TextStyle(fontFamily: primaryFont)
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  decoration: InputDecoration(
                      hintText: "Email",
                      border: OutlineInputBorder(),
                      errorText: errors[0] ? "Invalid email" : null
                  ),
                  style: TextStyle(fontFamily: primaryFont),
                  autofocus: true,
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  decoration: InputDecoration(
                      hintText: "Password",
                      border: OutlineInputBorder(),
                      errorText: errors[1] ? "Invalid password" : null),
                      style: TextStyle(fontFamily: primaryFont),
                  obscureText: true,
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextButton(
                    style: ButtonStyle(
                        minimumSize: WidgetStatePropertyAll(Size(125, 60)),
                        backgroundColor: WidgetStatePropertyAll((role == null || role != "doctor") ? Colors.transparent : Colors.blue),
                        foregroundColor: WidgetStatePropertyAll((role == null || role != "doctor") ? Colors.black : Colors.white),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          side: (role == null || role != "doctor") ? BorderSide(color: Colors.black) : BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(30)))),
                    onPressed: () {
                      setState(() {
                        if (role == null || role != "doctor") role = "doctor";
                        else role = null;
                      });
                    },
                    child:
                        Text("Doctor", style: TextStyle(fontFamily: primaryFont))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextButton(
                    style: ButtonStyle(
                      minimumSize: WidgetStatePropertyAll(Size(125, 60)),
                      backgroundColor: WidgetStatePropertyAll((role == null || role != "patient") ? Colors.transparent : Colors.blue),
                      foregroundColor: WidgetStatePropertyAll((role == null || role != "patient") ? Colors.black : Colors.white),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        side: (role == null || role != "patient") ? BorderSide(color: Colors.black) : BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(30)))),
                  onPressed: () {
                    setState(() {
                      if (role == null || role != "patient") role = "patient";
                      else role = null;
                    });
                  },
                  child:
                      Text("Patient", style: TextStyle(fontFamily: primaryFont))),)
                ],
              ),
              (errorText != null) ? Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(errorText!, style: TextStyle(color: Colors.red),),
              ) : Container(),
              TextButton(
                  style: ButtonStyle(
                      minimumSize: WidgetStatePropertyAll(Size(125, 60)),
                      backgroundColor: WidgetStatePropertyAll(Colors.blue),
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)))),
                  onPressed: () {
                    bool valid = validateInputs();
                    if (valid) signup();
                  },
                  child:
                      Text("Sign Up", style: TextStyle(fontFamily: primaryFont))),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextButton(onPressed: () {Navigator.popAndPushNamed(context, "/");}, child: Text("Already have an account? Login here!", style: TextStyle(fontFamily: primaryFont)))),
              
            ],
          ),
        ));
  }
}
