/// A file with helper dialog functions to easily display dialogs in the app.

import 'package:flutter/material.dart';

import 'loading_dialog.dart';

Future<dynamic> _showDialog(
  final BuildContext context,
  final Widget dialog,
  {final bool dismissable = true}
) {
  return showDialog(
    context: context,
    barrierDismissible: dismissable,
    builder: (BuildContext context) {
      return dialog;
    }
  );
}

void showLoadingDialog(final BuildContext context, final String text) {
  _showDialog(
    context,
    Loading(
      text: text
    ),
    dismissable: false
  );
}