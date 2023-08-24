/// The navigation part of the [Dashboard] page.
///
/// Allows viewing [Requests] based on the selected subject, as well as
/// filtering by [RequestFilter].

import 'package:flutter/material.dart';

import 'requests.dart';
import 'request_filter.dart';
import '../dashboard_page.dart';

class Navigation extends StatefulWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}


class _NavigationState extends State<Navigation> {
  final requestButtonColor = const Color(0xFFDF6C00);
  static const List<String> subjectList = [
    "COMP30019",
    "COMP30020",
    "COMP30021",
    "COMP30022",
    "COMP30023"
  ];
  String currentSubject = '';
  String userType = 'student';
  bool newRequest = false;



  List<Widget> _buildSubjectsColumn(List<String> subjects) {

    List<Widget> subjectWidgets = [];

    for (var subject in subjects) {
      subjectWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: MaterialButton(
            onPressed: () {
              // setState(() {
              //   currentSubject = subject;
              // });
              DashboardState().setCurrentSubject(subject);
            },
            child: Text(subject),
          ),
        ),
      );
    }
    return subjectWidgets;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          // Display new request button only if user is a student
          if (userType == 'student')
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: ElevatedButton (
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(requestButtonColor)),
                onPressed: () {
                  // temporary fix
                  DashboardState().setNewRequest(true);
                },
                child: const Text(
                  'New Request',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

          // TODO: Get user's subject list from database
          ..._buildSubjectsColumn(subjectList),
        ],
      ),

    );
  }
}