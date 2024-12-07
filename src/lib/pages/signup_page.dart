import "package:flutter/material.dart";
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
  String? errorText;
  List<bool> errors = [false, false];

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
        body: {"email": email, "password": password});

    var info = jsonDecode(response.body);

    if (response.statusCode == 200) {
      int user_id = info["user_id"];
      await SecureStorage.write("user_id", user_id.toString());
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
          title: Text("Signup"),
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
                      errorText: errors[0] ? "Invalid email" : null),
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
                  obscureText: true,
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
              ),
              TextButton(
                  onPressed: () {
                    bool valid = validateInputs();
                    if (valid) signup();
                  }, child: Text("Signup")),
              (errorText != null) ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(errorText!, style: TextStyle(color: Colors.red),),
              ) : Container()
            ],
          ),
        ));
  }
}
