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
  static const textFormFieldWidth = 400.0;
  
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final CollectionReference userRef = _db.collection('users');

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

  /// Attempt to authenticate the user with an [email] and [password].
  ///
  /// First try to match the given [email] and [password] to an already
  /// created Firebase Authentication account. If it doesn't exist,
  /// then try to create a new account with the given [email], but only if
  /// a user with the given [email] has signed in through Canvas first
  /// and is therefore already registered in the database. If a new account
  /// is created this way, also ensure that the user has verified their email
  /// address before being allowed to login, so as to not hijack another
  /// user's Canvas account.
  Future<void> _authenticate(String email, String password) async {
    try {
      // Attempt to sign in with an already existing account.
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

          // Ensure a new account has already signed in through Canvas before.
          if(userAlreadyExistsQuery.docs.isEmpty) {
            setState(() {
              _emailErrorMessage = 'Please initialise this email address through Canvas first';
              _passwordErrorMessage = null;
            });
            return;
          }

          // Create a new Firebase Authentication account for the user.
          try {
            await _auth.createUserWithEmailAndPassword(
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

  /// Begin the authentication flow.
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0.0,
        title: const Text('Sign in'),
        actions: [
          TextButton.icon(
            style: ButtonStyle(
              foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.surface),
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
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.background),
                    errorText: _emailErrorMessage,
                    fillColor: Theme.of(context).colorScheme.surface,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.surface, width: 2.0),
                    ),
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
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.background),
                  errorText: _passwordErrorMessage,
                  fillColor: Theme.of(context).colorScheme.surface,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.surface, width: 2.0),
                  ),
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
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Theme.of(context).colorScheme.secondary
                )
              ),
              onPressed: () => _attemptLogin(),
              child: Text(
                'Sign in',
                style: TextStyle(color: Theme.of(context).colorScheme.surface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}