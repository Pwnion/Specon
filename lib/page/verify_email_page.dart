/// A page that waits for email verification to complete.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({Key? key}) : super(key: key);

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    /// Poll for email verification every 5 seconds and exit loop if verified
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      await _auth.currentUser!.reload();
      return !_auth.currentUser!.emailVerified;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(
              width: 30,
            ),
            Text(
              'A verification email has been sent to your email address.\n'
              'Click the link in it to verify your account.',
              textAlign: TextAlign.center,
            )
          ],
        )
      )
    );
  }
}