/// The navigation part of the [Dashboard] page.
///
/// Allows viewing [Requests] based on the selected subject, as well as
/// filtering by [RequestFilter].

import 'package:flutter/material.dart';
import 'package:specon/backend.dart';
import 'package:specon/page/dashboard/request_filter.dart';
import 'package:specon/user_type.dart';
import 'package:specon/page/asm_mana.dart';

class Navigation extends StatefulWidget {
  final void Function() openNewRequestForm;
  final void Function(Map<String, dynamic>) setCurrentSubject;
  final Map<String, dynamic> currentUser;

  const Navigation(
      {Key? key,
      required this.openNewRequestForm,
      required this.setCurrentSubject,
      required this.currentUser})
      : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  final List<Map<String, dynamic>> subjectList =
      BackEnd().getSubjectList('userID'); // TODO: where to call

  String? selectedSubject;

  void selectSubject(String subjectCode) {
    setState(() {
      selectedSubject = subjectCode;
    });
  }

  List<Widget> _buildSubjectsColumn() {
    final List<Widget> subjectWidgets = [];

    // Add the "Subjects" text field
    subjectWidgets.add(
      const Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Text(
          "Subjects",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    // Create buttons for each subject
    for (final subject in subjectList) {
      subjectWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: MaterialButton(
            elevation: 0.0,
            color: subject['code'] == selectedSubject
                ? Theme.of(context).colorScheme.onBackground
                : Theme.of(context).colorScheme.background,
            onPressed: () {
              setState(() {
                if (subject['assessments'].isEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AsmManager(subject: subject),
                    ),
                  );
                } else {
                  selectSubject(subject['code']!);
                  widget.setCurrentSubject(subject);
                }
              });
            },
            child: Text(subject['code']!),
          ),
        ),
      );

      if (subject['assessments'].isNotEmpty &&
          subject['code'] == selectedSubject) {
        // Add a list of assessments for this subject
        for (final assessment in subject['assessments']) {
          subjectWidgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 40.0, top: 5.0),
              child: Align(
                alignment: Alignment.centerLeft, // Align text to the left
                child: Text(
                  assessment.name,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ),
          );
        }
      }
    }
    return subjectWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Display new request button only if user is a student
          if (widget.currentUser['userType'] == UserType.student &&
              selectedSubject != null)
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.secondary)),
                onPressed: () {
                  setState(() {
                    widget.openNewRequestForm();
                  });
                },
                child: Text(
                  'New Request',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.surface),
                ),
              ),
            ),
          ..._buildSubjectsColumn(),
        ],
      ),
    );
  }
}
