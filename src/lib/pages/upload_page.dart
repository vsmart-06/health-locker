import "dart:convert";
import "package:flutter/material.dart";
import "package:file_picker/file_picker.dart";
import "package:google_fonts/google_fonts.dart";
import "package:http/http.dart";
import "package:loading_animation_widget/loading_animation_widget.dart";
import "package:src/services/secure_storage.dart";
import "package:src/widgets/logout_button.dart";
import "package:syncfusion_flutter_pdfviewer/pdfviewer.dart";

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  late int user_id;
  late String role;
  bool login = false;
  List? categories;

  List<String> typeList = [
    "Choose a data type",
    "Diagnostic Reports",
    "Discharge Summaries",
    "Health Documents",
    "Immunization Records",
    "OP Consult Records",
    "Prescriptions",
    "Wellness Records",
    "Invoices"
  ];
  String displayText = "Choose a data type";
  var currentFile;
  var dcmImage;
  String? fileName;
  String? type;
  bool uploaded = false;
  bool sent = false;
  String? primaryFont = GoogleFonts.redHatDisplay().fontFamily;
  bool error = false;

  var controller = ScrollController();

  String baseUrl = "http://127.0.0.1:8000/health_locker";

  void pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(withData: true);

    if (result != null) {
      if (result.files.first.extension == "dcm") {
        var request = MultipartRequest(
            "POST", Uri.parse(baseUrl + "/convert-dicom/"));
        request.files.add(MultipartFile.fromBytes(
            "image", result.files.single.bytes!,
            filename: result.files.single.name));

        var response = await Response.fromStream(await request.send());

        setState(() {
          currentFile = result.files.single.bytes!;
          dcmImage = base64Decode(jsonDecode(response.body)["image"]);
          fileName = result.files.single.name;
          type = result.files.first.extension;
          uploaded = false;
          sent = false;
          error = false;
        });
      } else {
        setState(() {
          currentFile = result.files.single.bytes;
          fileName = result.files.single.name;
          type = result.files.single.extension;
          uploaded = false;
          sent = false;
          error = false;
        });
      }
    }
  }

  void sendFile() async {
    setState(() {
      uploaded = true;
      sent = false;
    });
    if (currentFile != null) {
      var request = MultipartRequest(
          "POST", Uri.parse(baseUrl + "/upload-file/"));
      request.files.add(
          MultipartFile.fromBytes("file", currentFile, filename: fileName));
      if (displayText == typeList.first) {
        return;
      }
      request.fields["type"] = displayText;
      request.fields["extension"] = type!;
      await loadUserId();
      request.fields["user_id"] = user_id.toString();
      if (role == "doctor") {
        String? email = await SecureStorage.read("patient_email");
        request.fields["patient"] = email!;
      }
      var response = await Response.fromStream(await request.send());

      if (response.statusCode != 200) {
        setState(() {
          error = true;
        });
        return;
      }

      setState(() {
        currentFile = null;
        fileName = null;
        type = null;
        displayText = typeList.first;
        sent = true;
        error = false;
      });
    }
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
      String? r = await SecureStorage.read("role");
      List<String>? cats;
      if (r == "doctor") {
        String? c = await SecureStorage.read("patient_categories");
        List cat = jsonDecode(c!);
        cats = cat.cast();
      }
      setState(() {
        user_id = int.parse(num!);
        role = r!;
        login = true;
        categories = cats;
        if (cats != null) {
          typeList = ["Choose a data type"] + cats;
        }
      });
    }
    else {
      await SecureStorage.delete();
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => route == "/");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUserId();
  }

  @override
  Widget build(BuildContext context) {
    if (!login) return LoadingAnimationWidget.inkDrop(color: Colors.blue, size: 100);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Upload a health record",
          style: TextStyle(fontFamily: primaryFont)
        ),
        centerTitle: true,
        actions: [LogoutButton()],
      ),
      body: SingleChildScrollView(
        controller: controller,
          child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all()),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton(
                        style: TextStyle(fontFamily: primaryFont),
                        value: displayText,
                        underline: (displayText != typeList.first)
                            ? Container(
                                height: 2,
                                color: Colors.blue,
                              )
                            : null,
                        items: typeList.map((String value) {
                          return DropdownMenuItem(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(fontFamily: primaryFont),
                              ));
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            displayText = value!;
                            uploaded = false;
                            error = false;
                          });
                        }),
                  ),
                ),
              ),
              (currentFile != null)
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Text(fileName!,
                          style: TextStyle(fontFamily: primaryFont)),
                    )
                  : Container(),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: TextButton(
                  style: ButtonStyle(
                      minimumSize: WidgetStatePropertyAll(Size(125, 60)),
                      foregroundColor: WidgetStatePropertyAll(Colors.black),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(10)))),
                  onPressed: () => pickFile(),
                  child: Text(
                      (currentFile == null) ? "Choose a file" : "Replace file",
                      style: TextStyle(fontFamily: primaryFont)),
                ),
              )
            ],
          ),
        ),
        (uploaded && displayText == "Choose a data type" && !sent)
            ? Text("No data type selected",
                style: TextStyle(fontFamily: primaryFont, color: Colors.red))
            : Container(),
        (uploaded && currentFile == null && !sent)
            ? Text("No file loaded", style: TextStyle(fontFamily: primaryFont, color: Colors.red))
            : Container(),
        (currentFile != null)
            ? Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                    maxHeight: MediaQuery.of(context).size.height * 0.5),
                child: ((type != "pdf")
                    ? (({"png", "jpg", "jpeg", "dcm"}.contains(type))
                        ? Image.memory(
                            (type != "dcm") ? currentFile! : dcmImage!)
                        : Text("$fileName uploaded",
                            style: TextStyle(fontFamily: primaryFont)))
                    : SfPdfViewer.memory(currentFile!)),
              )
            : Container(),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextButton(
              style: ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(Size(125, 60)),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
                  backgroundColor: WidgetStatePropertyAll(Colors.blue),
                  foregroundColor: WidgetStatePropertyAll(Colors.white)),
              onPressed: () => sendFile(),
              child: Text("Upload file",
                  style: TextStyle(fontFamily: primaryFont))),
        ),
        (sent)
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("File uploaded",
                    style: TextStyle(fontFamily: primaryFont)),
              )
            : Container(),
        (error && !sent)
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("A file with this name already exists",
                    style: TextStyle(fontFamily: primaryFont, color: Colors.red)),
              )
            : Container()
      ])),
    );
  }
}
