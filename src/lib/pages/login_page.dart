import "package:flutter/material.dart";
import "package:src/services/secure_storage.dart";
import "package:http/http.dart";
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

  String baseUrl = "http://127.0.0.1:8000/health_locker";

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

    } else if (response.statusCode == 401) {
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
          title: Text("Login"),
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
                      border: OutlineInputBorder(),),
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
                      border: OutlineInputBorder(),),
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
                    login();
                  }, child: Text("Login")),
              (errorText != null) ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(errorText!, style: TextStyle(color: Colors.red),),
              ) : Container()
            ],
          ),
        ));
  }
}
