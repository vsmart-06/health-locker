import "package:flutter/material.dart";
import "package:src/services/secure_storage.dart";
import "package:http/http.dart";
import "package:google_fonts/google_fonts.dart";
import "dart:core";
import "dart:convert";

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = "";
  String password = "";
  String? errorText;
  List<bool> errors = [false, false];
  String? primaryFont = GoogleFonts.redHatDisplay().fontFamily;

  String baseUrl = "http://127.0.0.1:8000/health_locker";

  bool validateInputs() {
    setState(() {
      errors = [
        email.isEmpty,
        password.isEmpty
      ];
    });
    return (!errors[0] && !errors[1]);
  }

  void login() async {
    var response = await post(Uri.parse(baseUrl + "/login/"),
        body: {"email": email, "password": password});

    var info = jsonDecode(response.body);

    if (response.statusCode == 200) {
      int user_id = info["user_id"];
      await SecureStorage.write("user_id", user_id.toString());
      await Navigator.popAndPushNamed(context, "/home",
          arguments: {"user_id": user_id});
      return;
    } else if (response.statusCode >= 400) {
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
            "Login",
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
                    errorText: errors[0] ? "Email cannot be empty" : null
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
                    errorText: errors[1] ? "Password cannot be empty" : null
                  ),
                  style: TextStyle(fontFamily: primaryFont),
                  obscureText: true,
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
              ),
              (errorText != null)
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        errorText!,
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : Container(),
              TextButton(
                  style: ButtonStyle(
                      minimumSize: WidgetStatePropertyAll(Size(125, 60)),
                      backgroundColor: WidgetStatePropertyAll(Colors.blue),
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)))),
                  onPressed: () {
                    bool valid = validateInputs();
                    if (valid) login();
                  },
                  child:
                      Text("Login", style: TextStyle(fontFamily: primaryFont))),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextButton(onPressed: () {Navigator.popAndPushNamed(context, "/signup");}, child: Text("Don't have an account yet? Sign up here!", style: TextStyle(fontFamily: primaryFont))),
              )
            ],
          ),
        ));
  }
}
