import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastDialog {
  static error(String msg) {
    showToast("error", msg);
  }

  static warning(String msg) {
    showToast("warning", msg);
  }

  static success(String msg) {
    showToast("success", msg);
  }

  static showToast(String type, String msg) {
    Color textColor = const Color(0xff4F8A10);
    Color bgColor = const Color(0xffDFF2BF);
    dynamic webBgColor = "#FFD2D2";
    if (type == "success") {
      textColor = const Color(0xff4F8A10);
      bgColor = const Color(0xffDFF2BF);
      webBgColor = "#DFF2BF";
    } else if (type == "warning") {
      textColor = const Color(0xff9F6000);
      bgColor = const Color(0xffFEEFB3);
      webBgColor = "#FEEFB3";
    } else if (type == "error") {
      textColor = const Color(0xffD8000C);
      bgColor = const Color(0xffFFD2D2);
      webBgColor = "#FFD2D2";
    }

    Fluttertoast.showToast(
        msg: msg,
        timeInSecForIosWeb: 2,
        textColor: textColor,
        backgroundColor: bgColor,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG,
        webShowClose: true,
        webPosition: "center",
        webBgColor: webBgColor);
  }
}

Future<T?> showConfirmationDialog<T>(
    {required BuildContext context,
    required String body,
    required Function onPressedOk,
    String? okText,
    String? cancelText,
    String? title}) {
  return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title ?? "Confirmation",
              style: const TextStyle(fontSize: 20, color: Colors.black)),
          content: Text(body,
              style: const TextStyle(fontSize: 14, color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: <Widget>[
            TextButton(
                child: Text(
                  cancelText ?? "CANCEL",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                onPressed: () => Navigator.of(dialogContext).pop()),
            TextButton(
                child: Text(
                  okText ?? "OK",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  onPressedOk();
                })
          ],
        );
      });
}
