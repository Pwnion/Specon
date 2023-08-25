/// The navigation part of the [Dashboard] page.
///
/// Allows viewing [Requests] based on the selected subject, as well as
/// filtering by [RequestFilter].

import 'package:flutter/material.dart';
import 'package:specon/page/dashboard/request_filter.dart';

class Navigation extends StatefulWidget {

  final Function openNewRequestForm;
  final Function setCurrentSubject;
  final String userType;

  const Navigation(
    {
    Key? key,
    required this.openNewRequestForm,
    required this.setCurrentSubject,
    required, required this.userType
    }
  ) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {

  // TODO: Get user's enrolled subject from canvas
  List<Map<String, String>> subjectList = [
    {'code': 'COMP10001', 'name': 'Foundations of Computing'},
    {'code': 'COMP10002', 'name': 'Foundations of Algorithms'},
    {'code': 'COMP20003', 'name': 'Algorithms and Data Structures'},
    {'code': 'COMP20005', 'name': 'Intro. to Numerical Computation in C'},
    {'code': 'COMP20007', 'name': 'Design of Algorithms'},
    {'code': 'COMP20008', 'name': 'Elements of Data Processing'},
    {'code': 'SWEN20003', 'name': 'Object Oriented Software Development'},
    {'code': 'COMP30013', 'name': 'Advanced Studies in Computing'},
    {'code': 'COMP30019', 'name': 'Graphics and Interaction'},
    {'code': 'COMP30020', 'name': 'Declarative Programming'},
    {'code': 'COMP30022', 'name': 'IT Project'},
    {'code': 'COMP30023', 'name': 'Computer Systems'},
    {'code': 'COMP30024', 'name': 'Artificial Intelligence'},
    {'code': 'COMP30026', 'name': 'Models of Computation'},
    {'code': 'COMP30027', 'name': 'Machine Learning'},
    {'code': 'SWEN30006', 'name': 'Software Modelling and Design'},
  ];

  final requestButtonColor = MaterialStateProperty.all(const Color(0xFFDF6C00));
  final secondary = const Color(0xFF333333);
  final onSecondary = const Color(0xFFA7A7A7);
  String selectedSubject = '';

  List<Widget> _buildSubjectsColumn() {

    List<Widget> subjectWidgets = [];

    for (var subject in subjectList) {

      subjectWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: MaterialButton(
            elevation: 0.0,
            color: subject['code'] == selectedSubject ? onSecondary : secondary,
            onPressed: () {
              setState(() {
                selectedSubject = subject['code']!;
                widget.setCurrentSubject(subject);
              });
            },
            child: Text(subject['code']!),
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
              style: ButtonStyle(backgroundColor: requestButtonColor),
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

        ..._buildSubjectsColumn(),
      ],
    );
  }
}