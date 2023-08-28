/// The navigation part of the [Dashboard] page.
///
/// Allows viewing [Requests] based on the selected subject, as well as
/// filtering by [RequestFilter].

import 'package:flutter/material.dart';
import 'package:specon/backend.dart';
import 'package:specon/page/dashboard/request_filter.dart';
import 'package:specon/user_type.dart';

class Navigation extends StatefulWidget {

  final Function openNewRequestForm;
  final Function setCurrentSubject;
  final Map currentUser;

  const Navigation(
    {
    Key? key,
    required this.openNewRequestForm,
    required this.setCurrentSubject,
    required this.currentUser
    }
  ) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {

  // TODO: Get user's enrolled subject from canvas
  List<Map<String, String>> subjectList = BackEnd().getSubjectList("userID"); // TODO: where to call

  final requestButtonColor = MaterialStateProperty.all(const Color(0xFFDF6C00));
  final secondary = const Color(0xFF333333);
  final onSecondary = const Color(0xFFA7A7A7);
  String selectedSubject = '';
  Map currentUser = {}; // Get from dashboard

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
  void initState() {
    currentUser = widget.currentUser;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

        // Display new request button only if user is a student
        if (currentUser['userType'] == UserType.student && selectedSubject != '')
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