/// Redirects to the [Login] or [Dashboard] page based on authentication state.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:specon/page/verify_email_page.dart';

import 'dashboard_page.dart';
import 'loading_page.dart';
import 'login_page.dart';

import '../user_type.dart';

class Landing extends StatelessWidget {
  const Landing({super.key});

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.userChanges(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if(user == null) {
            return const Login();
          }

          if(!user.emailVerified) {
            user.sendEmailVerification();
            return const VerifyEmail();
          }

          return const Dashboard(
            userType: UserType.student, // TODO: Get actual type from Canvas.
          );
        }
        return const Loading();
      },
    );
  }
}