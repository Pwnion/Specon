/// The page for logging in to the application.
///
/// This page will never be shown if the application is opened via Canvas.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../dialog/dialog_helper.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final CollectionReference userRef = _db.collection('users');

  final topBarColor = const Color(0xFF385F71);
  final mainBodyColor = const Color(0xFF333333);
  final textFormFieldWidth = 400.0;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailErrorMessage;
  String? _passwordErrorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _authenticate(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
    } on FirebaseAuthException catch (e) {
      switch(e.code) {
        case 'invalid-email':
          setState(() {
            _emailErrorMessage = 'Please enter a valid email address';
            _passwordErrorMessage = null;
          });
          return;
        case 'user-disabled':
          setState(() {
            _emailErrorMessage = 'This account has been disabled';
            _passwordErrorMessage = null;
          });
          return;
        case 'missing-password':
          setState(() {
            _emailErrorMessage = null;
            _passwordErrorMessage = 'Please enter a password';
          });
          return;
        case 'wrong-password':
          setState(() {
            _emailErrorMessage = null;
            _passwordErrorMessage = 'Incorrect password';
          });
          return;
        case 'too-many-requests':
          setState(() {
            _emailErrorMessage = 'Too many requests: try again later';
            _passwordErrorMessage = null;
          });
          return;
        case 'user-not-found':
          final QuerySnapshot userAlreadyExistsQuery = await userRef.where(
            'email',
            isEqualTo: email
          ).get();
          if(userAlreadyExistsQuery.docs.isEmpty) {
            setState(() {
              _emailErrorMessage = 'Please initialise this email address through Canvas first';
              _passwordErrorMessage = null;
            });
            return;
          }

          try {
            final UserCredential creds = await _auth.createUserWithEmailAndPassword(
              email: email,
              password: password
            );
          } on FirebaseAuthException catch (e) {
            if(e.code == 'weak-password') {
              setState(() {
                _emailErrorMessage = null;
                _passwordErrorMessage = 'Password is too weak';
              });
            }
          }
          return;
      }
    }
  }

  void _attemptLogin() async {
    showLoadingDialog(
      context,
      'Logging in...'
    );

    await _authenticate(
      _emailController.text,
      _passwordController.text
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBodyColor,
      appBar: AppBar(
        backgroundColor: topBarColor,
        elevation: 0.0,
        title: const Text('Sign in'),
        actions: [
          TextButton.icon(
            style: const ButtonStyle(
              foregroundColor: MaterialStatePropertyAll(Colors.white),
            ),
            icon: const Icon(Icons.person),
            label: const Text('Register'),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 50.0
        ),
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            Center(
              child: SizedBox(
                width: textFormFieldWidth,
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    errorText: _emailErrorMessage,
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2.0),
                    ),
                    // focusedBorder: const OutlineInputBorder(
                    //   borderSide: BorderSide(color: Colors.pink, width: 2.0),
                    // ),
                  ),
                  onChanged: (value) {
                    if(_emailErrorMessage != null) {
                      setState(() => _emailErrorMessage = null);
                    }
                  }
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: textFormFieldWidth,
              child: TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  errorText: _passwordErrorMessage,
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                  ),
                  // focusedBorder: const OutlineInputBorder(
                  //   borderSide: BorderSide(color: Colors.pink, width: 2.0),
                  // ),
                ),
                obscureText: true,
                onChanged: (value) {
                  if(_passwordErrorMessage != null) {
                    setState(() => _passwordErrorMessage = null);
                  }
                },
                onFieldSubmitted: (_) => _attemptLogin(),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Color(0xFFDF6C00)
                )
              ),
              onPressed: () => _attemptLogin(),
              child: const Text(
                'Sign in',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}