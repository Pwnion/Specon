/// Redirects to the [Login] or [Dashboard] page based on authentication state.
///
/// Author: Aden McCusker

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:specon/functions.dart';
import 'package:specon/models/user_model.dart';
import 'package:specon/page/verify_email_page.dart';

import '../../db.dart';
import '../dashboard_page.dart';
import 'loading_page.dart';
import '../login_page.dart';

import '../../user_type.dart';

class Landing extends StatefulWidget {
  final String? email;

  const Landing({Key? key, this.email}) : super(key: key);

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final _database = DataBase();

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
        canvasLogout: _canvasLogout
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

          // Refresh the user's access token when loggin in externally.
          _database.getUserFromEmail(_auth.currentUser!.email!).then((user) {
            refreshAccessToken(user.uuid);
          });

          // Otherwise, navigate to the main dashboard.
          return const Dashboard();
        }
        return const Loading();
      },
    );
  }
}