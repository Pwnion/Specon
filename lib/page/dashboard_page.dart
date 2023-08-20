/// The main page for an authenticated user.
///
/// Content changes based on the [UserType] that is authenticated.

import 'package:flutter/material.dart';

import '../user_type.dart';
import 'dashboard/requests.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('specon'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
              child: Container(
                color: Colors.black12,
                child: Text('subject')
              )
          ),
          Expanded(
            flex: 2,
              child: Container(
                  child: Requests(),
              )
          ),
          Expanded(
            flex: 5,
              child: Container(
                color: Colors.black12,
              )
          ),
        ],
      ),
    );
  }
}