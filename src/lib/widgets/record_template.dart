// ignore_for_file: must_be_immutable

import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:http/http.dart";
import "package:loading_animation_widget/loading_animation_widget.dart";
import "package:src/services/secure_storage.dart";
import "package:src/widgets/logout_button.dart";
import "dart:convert";

import "package:syncfusion_flutter_pdfviewer/pdfviewer.dart";

class RecordsTemplate extends StatefulWidget {
  String? title;
  RecordsTemplate({super.key, required this.title});

  @override
  State<RecordsTemplate> createState() => _RecordsTemplateState();
}

class _RecordsTemplateState extends State<RecordsTemplate> {
  late int user_id;
  bool login = false;

  List<Widget> rowData = [];
  late Map data;
  List selected = [];

  String? primaryFont = GoogleFonts.redHatDisplay().fontFamily;

  String baseUrl = "http://127.0.0.1:8000/health_locker";

  void getData() async {
    await loadUserId();
    var response = await post(
        Uri.parse(baseUrl + "/fetch-data/"),
        body: {"type": widget.title, "user_id": user_id.toString()});
    var info = jsonDecode(response.body)["data"];
    setState(() {
      data = info;
    });

    loadData();
  }

  Widget previewData(Map info) {
    Widget previewFile = Container();
    if (info["data"]["extension"] == "dcm") {
      previewFile = Image.memory(
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          return Container(
            constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
          maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: child,
          );
        },
        base64Decode(info["data"]["image"])
      );
    } 
    else if ({"png", "jpg", "jpeg"}.contains(info["data"]["extension"])) {
      previewFile = Image.memory(
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          return Container(
            constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
          maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: child,
          );
        },
        base64Decode(info["data"]["file"]));
    } 
    else if (info["data"]["extension"] == "pdf") {
      previewFile = SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          child: SfPdfViewer.memory(base64Decode(info["data"]["file"])));
    }
    else if (info["data"]["extension"] == "json") {
      Map file = info["data"]["file"];
      if (file.containsKey("contentType") && file["contentType"] == "application/pdf") {
        previewFile = SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          child: SfPdfViewer.memory(base64Decode(file["data"])));
      }
    }
    return previewFile;
  }

  TextButton fileButton(Map info) {
    TextButton button = TextButton(
      onLongPress: () {
        setState(() {
          if (selected.contains(info["file_name"])) {
            selected.remove(info["file_name"]);
          } else {
            selected.add(info["file_name"]);
          }
        });
        loadData();
      },
      onPressed: () {
        if (selected.isEmpty) {
          showDialog(context: context, builder: (BuildContext context) {
            return Dialog(
              child: previewData(info),
              insetAnimationDuration: Duration(milliseconds: 50),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            );
          });
          return;
        }
        setState(() {
          if (selected.contains(info["file_name"])) {
            selected.remove(info["file_name"]);
          } else {
            selected.add(info["file_name"]);
          }
          
        });
        loadData();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          (info["data"]["extension"] != "pdf")
              ? ((info["data"]["extension"] != "json") ? Icon(Icons.image) : Icon(Icons.health_and_safety))
              : Icon(Icons.picture_as_pdf),
          SizedBox(
            width: 10,
          ),
          Text(
            info["data"]["file_name"],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        minimumSize: WidgetStatePropertyAll(
            Size(MediaQuery.of(context).size.width * 0.15, 85)),
        backgroundColor: (!selected.contains(info["file_name"])) ? WidgetStatePropertyAll(Colors.grey[300]) : WidgetStatePropertyAll(Colors.lightBlue[100]),
        foregroundColor: WidgetStatePropertyAll(Colors.black),
      ),
    );

    return button;
  }

  void loadData() {
    rowData = [];
    for (String x in data.keys) {
      rowData.add(Padding(
        padding: const EdgeInsets.all(20.0),
        child: fileButton(data[x]),
      ));
    }
    setState(() {
      rowData = rowData;
    });
  }

  void deleteData() async {
    String files = "[";
    for (int i = 0; i < selected.length; i++) {
      files += "\"${selected[i]}\"";
      if (i != selected.length-1) {
        files += ", ";
      }
    }
    files += "]";

    var response = await post(
        Uri.parse(baseUrl + "/delete-data/"),
        body: {"type": widget.title, "user_id": user_id.toString(), "files": files});

    if (response.statusCode != 200) {
      print("Error occured");
      return;
    }

    setState(() {
      selected = [];
    });

    getData();
  }

  Future<bool> checkLogin() async {
    Map<String, String> info = await SecureStorage.read();
    if (info["last_login"] != null) {
      DateTime date = DateTime.parse(info["last_login"]!);
      if (DateTime.now().subtract(Duration(days: 30)).compareTo(date) >= 0) {
        return false;
      }
    }
    return (info["user_id"] != null);
  }

  Future<void> loadUserId() async {
    if (await checkLogin()) {
      String? num = await SecureStorage.read("user_id");
      setState(() {
        user_id = int.parse(num!);
        login = true;
      });
    }
    else {
      await SecureStorage.delete();
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => route == "/");
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    if (!login) return LoadingAnimationWidget.inkDrop(color: Colors.blue, size: 100);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title!,
          style: TextStyle(fontFamily: primaryFont)
        ),
        centerTitle: true,
        actions: [LogoutButton()],
      ),
      body: Scaffold(
          body: rowData.isEmpty ? Center(child: LoadingAnimationWidget.inkDrop(color: Colors.blue, size: 100)) : Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.count(
                childAspectRatio:
                    ((MediaQuery.of(context).size.width * 0.15) / 85),
                shrinkWrap: true,
                crossAxisCount: 5,
                children: List.generate(rowData.length, (index) {
                  return rowData[index];
                }),
              ))),
      floatingActionButton: (selected.isNotEmpty)
          ? FloatingActionButton(
              onPressed: () => deleteData(),
              child: Icon(Icons.delete_outlined),
            )
          : null,
    );
  }
}
