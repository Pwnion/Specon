/// The main page for an authenticated user.
///
/// Content changes based on the [UserType] that is authenticated.

import 'package:flutter/material.dart';

import '../user_type.dart';

class Dashboard extends StatefulWidget {
  final UserType userType;

  const Dashboard(
    {
      Key? key,
      required this.userType
    }
  ) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}