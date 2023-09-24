/// A file with helper dialog functions to easily display dialogs in the app.
///
/// Author: Aden McCusker

import 'package:flutter/material.dart';

import 'loading_dialog.dart';

/// Display a given widget as a popup dialog.
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

/// Display a loading dialog with a custom [message].
void showLoadingDialog(final BuildContext context, final String message) {
  _showDialog(
    context,
    Loading(
      text: message
    ),
    dismissable: false
  );
}