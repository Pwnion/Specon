/// The page for logging in to the application.
///
/// This page will never be shown if the application is opened via Canvas.

import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final _formKey = GlobalKey<FormState>();
  final topBarColor = const Color(0xFF385F71);
  final mainBodyColor = const Color(0xFF333333);
  final textFormFieldWidth = 400.0;

  String email = '';
  String password = '';

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

        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),

        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20.0),

              Center(
                child: SizedBox(
                  width: textFormFieldWidth,
                  child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink, width: 2.0),
                        ),
                      ),
                      validator: (value) {
                        return value!.isEmpty ? 'Enter an email' : null;
                      },
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      }
                  ),
                ),
              ),

              const SizedBox(height: 20.0),

              SizedBox(
                width: textFormFieldWidth,
                child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink, width: 2.0),
                      ),
                    ),
                    validator: (value) {
                      return value!.length < 6
                          ? 'Enter a password 6+ characters long'
                          : null;
                    },
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    }
                ),
              ),

              const SizedBox(height: 20.0),

              ElevatedButton(
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(
                    Color(0xFFDF6C00))),
                onPressed: () async {

                },
                child: const Text(
                  'Sign in',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}