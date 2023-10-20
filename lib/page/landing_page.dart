/// Redirects to the [Login] or [Dashboard] page based on authentication state.
///
/// Author: Aden McCusker

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:specon/page/verify_email_page.dart';

import 'dashboard_page.dart';
import 'loading_page.dart';
import 'login_page.dart';

import '../user_type.dart';

class Landing extends StatefulWidget {
  final String? email;

  const Landing({Key? key, this.email}) : super(key: key);

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  late bool _canvasLogin;

  void _canvasLogout() {
    setState(() {
      _canvasLogin = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _canvasLogin = widget.email != null;
  }

  @override
  Widget build(BuildContext context) {
    if(_canvasLogin) {
      return Dashboard(
        canvasEmail: widget.email,
        canvasLogout: _canvasLogout,
        userType: UserType.student,
      );
    }

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