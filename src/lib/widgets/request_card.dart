// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

class DataRequest extends StatefulWidget {
  int? request_id;
  String? status;
  List? categories;
  String? other;
  String? expiration;
  String? role;
  Function? callback;
  DataRequest(
      {super.key,
      required this.request_id,
      required this.status,
      required this.categories,
      required this.other,
      required this.expiration,
      required this.role,
      required this.callback});

  @override
  State<DataRequest> createState() => _DataRequestState();
}

class _DataRequestState extends State<DataRequest> {
  String? primaryFont = GoogleFonts.redHatDisplay().fontFamily;

  double fontSize = 18;

  String baseUrl = "http://127.0.0.1:8000/health_locker";

  Widget statusWidget(String status) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
            color: (status == "approved")
                ? Colors.green
                : ((status == "declined"
                    ? Colors.red
                    : ((status == "pending") ? Colors.grey : Colors.yellow))),
            border: Border.all(),
            borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text(
            status.substring(0, 1).toUpperCase() + status.substring(1),
            style: TextStyle(
                color: (status != "expired") ? Colors.white : Colors.black,
                fontFamily: primaryFont,
                fontStyle: FontStyle.italic),
          ),
        ),
      ),
    );
  }

  Widget toggleWidget(String status, BuildContext dialogContext) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextButton(
          onPressed: () async {
            if (status != "withdraw") {
              await post(Uri.parse(baseUrl + "/toggle-request/"), body: {
                "request_id": widget.request_id.toString(),
                "status": status
              });
              Navigator.pop(dialogContext);
            }
            else {
              await post(Uri.parse(baseUrl + "/withdraw-request/"), body: {
                "request_id": widget.request_id.toString(),
              });
              Navigator.of(dialogContext).pop();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              (status == "approved") ? "Accept" : (status == "declined") ? "Decline" : "Withdraw",
              style: TextStyle(
                  fontFamily: primaryFont,
                  color: Colors.white,
                  fontSize: fontSize),
            ),
          ),
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                  (status == "approved") ? Colors.green : (status == "declined") ? Colors.red : Colors.grey),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        statusWidget(widget.status!),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              color: (widget.status == "pending") ? Colors.yellow[50] : null,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: TextButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext dContext) {
                      return Dialog(
                        insetAnimationDuration: Duration(milliseconds: 50),
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            constraints: BoxConstraints(
                                minHeight:
                                    MediaQuery.of(context).size.height * 0.6),
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${(widget.role == 'patient') ? 'Doctor' : 'Patient'}: ${widget.other!}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: primaryFont,
                                              fontSize: fontSize),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 10, 0, 10),
                                          child: Text(
                                            "Expires at: ${widget.expiration!}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: primaryFont,
                                                fontSize: fontSize),
                                          ),
                                        ),
                                        Text(
                                          "Categories:\n${widget.categories!.map((x) => '    -    ${x}').join('\n')}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: primaryFont,
                                              fontSize: fontSize),
                                        ),
                                      ],
                                    ),
                                    (widget.status != "pending" || widget.role != "patient")
                                        ? ((widget.status == "pending" && widget.role == "doctor") ? Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: toggleWidget("withdraw", context),
                                          ) : statusWidget(widget.status!))
                                        : Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                toggleWidget(
                                                    "approved", dContext),
                                                toggleWidget(
                                                    "declined", dContext)
                                              ],
                                            ),
                                          )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).then((value) => widget.callback!()),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "${(widget.role == 'patient') ? 'Doctor' : 'Patient'}: ${widget.other!}",
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: primaryFont,
                              fontSize: fontSize),
                        ),
                        Text(
                          "Expires at: ${widget.expiration!}",
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: primaryFont,
                              fontSize: fontSize),
                        )
                      ]),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
