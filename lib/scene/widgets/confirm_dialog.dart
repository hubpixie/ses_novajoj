import 'package:flutter/material.dart';

class ConfirmDialog {
  static final ConfirmDialog _instance = ConfirmDialog._internal();
  factory ConfirmDialog() {
    return _instance;
  }
  ConfirmDialog._internal();

  void show(BuildContext context,
      {String? title,
      required message,
      required List<String> buttonTitles,
      required List<void Function()?> actions}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // set up the buttons
          List<Widget> buttons = [];
          buttonTitles.asMap().forEach((idx, value) {
            buttons
                .add(TextButton(onPressed: actions[idx], child: Text(value)));
          });
          return AlertDialog(
            title: title == null ? null : Text(title),
            content: Text(message),
            actions: buttons,
          ); // show the dialog
        },
        barrierDismissible: false);
  }
}
