/// The navigation part of the [Dashboard] page.
///
/// Allows viewing [Requests] based on the selected subject, as well as
/// filtering by [RequestFilter].

import 'package:flutter/material.dart';

import 'requests.dart';
import 'request_filter.dart';
import '../dashboard_page.dart';

class Navigation extends StatefulWidget {

  final Function openNewRequestForm;
  final Function setCurrentSubject;
  final String userType;

  const Navigation({Key? key, required this.openNewRequestForm, required this.setCurrentSubject, required, required this.userType}) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {


  final requestButtonColor = const Color(0xFFDF6C00);
  final secondary = const Color(0xFF333333);
  final onSecondary = const Color(0xFFA7A7A7);
  String selectedSubject = '';

  // TODO: Get user's enrolled subject
  static const List<String> subjectList = [
    "COMP30019",
    "COMP30020",
    "COMP30021",
    "COMP30022",
    "COMP30023"
  ];

  List<Widget> _buildSubjectsColumn(List<String> subjects) {

    List<Widget> subjectWidgets = [];

    for (var subject in subjects) {

      subjectWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: MaterialButton(
            elevation: 0.0,
            color: subject == selectedSubject ? onSecondary : secondary,
            onPressed: () {
              setState(() {
                selectedSubject = subject;
                widget.setCurrentSubject(subject);
              });
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

        // Display new request button only if user is a student
        if (widget.userType == 'student')
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
            child: ElevatedButton (
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(requestButtonColor)),
              onPressed: () {
                setState(() {
                  widget.openNewRequestForm();
                });
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
    );
  }
}