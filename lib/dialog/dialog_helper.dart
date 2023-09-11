import 'package:flutter/material.dart';

import 'loading_dialog.dart';

Future<dynamic> _showDialog(BuildContext context, Widget dialog, {bool dismissable = true}) {
  return showDialog(
    context: context,
    barrierDismissible: dismissable,
    builder: (BuildContext context) {
      return dialog;
    }
  );
}

void showLoadingDialog(BuildContext context, String text) {
  _showDialog(
    context,
    Loading(
      text: text
    ),
    dismissable: false
  );
}