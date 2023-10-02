/// The navigation part of the [Dashboard] page.
///
/// Allows viewing [Requests] based on the selected subject, as well as
/// filtering by [RequestFilter].

import 'package:flutter/material.dart';
import 'package:specon/models/userModel.dart';
import 'package:specon/page/dashboard/request_filter.dart';
import 'package:specon/page/db.dart';
import 'package:specon/user_type.dart';
import 'package:specon/page/asm_mana.dart';
import 'package:specon/models/subject_model.dart';

class Navigation extends StatefulWidget {
  final void Function() openNewRequestForm;
  final void Function(SubjectModel) setCurrentSubject;
  final void Function(List<SubjectModel>) setSubjectList;
  final UserModel currentUser;
  final SubjectModel currentSubject;
  final void Function(String) getSelectedAssessment;

  const Navigation(
      {Key? key,
      required this.openNewRequestForm,
      required this.setCurrentSubject,
      required this.setSubjectList,
      required this.currentUser,
      required this.currentSubject,
      required this.getSelectedAssessment})
      : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  SubjectModel? selectedSubject;
  static final _db = DataBase();
  List<SubjectModel> subjectList = [];
  bool fetchingFromDB = true;

  void selectSubject(SubjectModel subject) {
    setState(() {
      selectedSubject = subject;
    });
  }

  List<Widget> _buildSubjectsColumn(List<SubjectModel> subjectList) {
    final List<Widget> subjectWidgets = [];

    // Create buttons for each subject
    for (final subject in subjectList) {
      subjectWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: MaterialButton(
            elevation: 0.0,
            color: subject == selectedSubject
                ? Theme.of(context).colorScheme.onBackground
                : Theme.of(context).colorScheme.background,
            onPressed: () {
              setState(() {
                if (subject.assessments.isEmpty &&
                    widget.currentUser.role == UserType.subjectCoordinator) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AsmManager(
                        subject: subject,
                        refreshFn: setState,
                      ),
                    ),
                  );
                } else {
                  selectSubject(subject);
                  widget.setCurrentSubject(subject);
                }
              });
            },
            child: Text(subject.code),
          ),
        ),
      );

      if (subject.assessments.isNotEmpty && subject == selectedSubject) {
        // Add "All Assessments" option at the top
        subjectWidgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 50.0, top: 5.0),
            child: Align(
              alignment: Alignment.centerLeft, // Align text to the left
              child: InkWell(
                onTap: () {
                  widget.getSelectedAssessment("All");
                },
                child: Text(
                  "All",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        );

        // Add a list of assessments for this subject
        for (final assessment in subject.assessments) {
          subjectWidgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 50.0, top: 5.0),
              child: Align(
                alignment: Alignment.centerLeft, // Align text to the left
                child: InkWell(
                  onTap: () {
                    widget.getSelectedAssessment(assessment.name);
                  },
                  child: Text(
                    assessment.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
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
  void initState() {
    _db.getEnrolledSubjects().then((subjects) {
      subjectList = subjects;
      fetchingFromDB = false;
      widget.setSubjectList(subjects);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!fetchingFromDB) {
      if (widget.currentSubject != selectedSubject) {
        selectedSubject = widget.currentSubject;
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Display new request button only if user is a student
          if (widget.currentUser.role == UserType.student)
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
          ..._buildSubjectsColumn(subjectList),
        ],
      );
    } else {
      return const CircularProgressIndicator();
    }
  }
}
