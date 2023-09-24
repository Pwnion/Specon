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

          // If the user isn't authenticated, navigate to the Login page.
          if(user == null) {
            return const Login();
          }

          // If the user's email isn't verified, navigate to the VerifyEmail page.
          if(!user.emailVerified) {
            user.sendEmailVerification();
            return const VerifyEmail();
          }

          // Otherwise, navigate to the main dashboard with the appropriate permissions.
          return const Dashboard(
            userType: UserType.subjectCoordinator, // TODO: Get actual type from Canvas.
          );
        }
        return const Loading();
      },
    );
  }
}