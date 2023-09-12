/// An error page for when things have really gone wrong.

import 'package:flutter/material.dart';

class Error extends StatelessWidget {
  const Error({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Center(
        child: Text(
          'A fatal error has occurred. Please refresh to try again.',
          style: TextStyle(
            fontSize: 32.0
          ),
        )
      )
    );
  }
}