// ignore_for_file: must_be_immutable

import "package:flutter/material.dart";
import "package:http/http.dart";
import "dart:convert";

import "package:syncfusion_flutter_pdfviewer/pdfviewer.dart";

class RecordsTemplate extends StatefulWidget {
  String? title;
  RecordsTemplate({super.key, required this.title});

  @override
  State<RecordsTemplate> createState() => _RecordsTemplateState();
}

class _RecordsTemplateState extends State<RecordsTemplate> {
  List<Widget> rowData = [];
  late Map data;
  List selected = [];

  String baseUrl = "http://127.0.0.1:8000/health_locker";

  void getData() async {
    var response = await post(
        Uri.parse(baseUrl + "/retrieve-data/"),
        body: {"type": widget.title, "user_id": "1"});
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
        body: {"type": widget.title, "user_id": "1", "files": files});
    var info = jsonDecode(response.body);
    setState(() {
      selected = [];
    });
    getData();
    if (info.containsKey("error")) {
      print("Error occured");
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
        centerTitle: true,
      ),
      body: Scaffold(
          body: Padding(
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
