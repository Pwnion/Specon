/// The main page for an authenticated user.
///
/// Content changes based on the [UserType] that is authenticated.

import 'package:flutter/material.dart';
import 'package:specon/specon_form.dart';
import 'package:specon/page/asm_mana.dart';
import 'package:specon/page/dashboard/navigation.dart';
import 'package:specon/page/dashboard/requests.dart';
import 'package:specon/page/dashboard/discussion.dart';
import 'package:specon/page/permission.dart';
import 'package:specon/user_type.dart';
import 'package:specon/model/subject.dart';

import '../mock_data.dart';

class Dashboard extends StatefulWidget {
  final UserType userType;

  const Dashboard({Key? key, required this.userType}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final stopwatch = Stopwatch();
  Subject currentSubject = Subject(name: "", code: "", assessments: []);
  Map<String, dynamic> currentRequest = {};
  bool avatarIsPressed = false;
  bool newRequest = false;
  bool showSubmittedRequest = false;
  bool openPermissionPanel = false;
  String studentName = '';
  Widget? requestWidget;
  Widget? discussionWidget;

  void openSubmittedRequest(Map<String, dynamic> currentRequest) {
    setState(() {
      showSubmittedRequest = true;
      newRequest = false;
      this.currentRequest = currentRequest;
    });
  }

  String getCurrentSubjectCode() {
    return currentSubject.code;
  }

  void openNewRequestForm() {
    setState(() {
      newRequest = true;
      showSubmittedRequest = false;
    });
  }

  Map<String, dynamic> getCurrentRequest() {
    return currentRequest;
  }

  void closeNewRequestForm() {
    setState(() {
      newRequest = false;
    });
  }

  void setCurrentSubject(Subject subject) {
    setState(() {
      currentSubject = subject;
      requestWidget;
      showSubmittedRequest = false;
      newRequest = false;
    });
  }

  Widget displayThirdColumn() {
    if (newRequest) {
      return SpeconForm(closeNewRequestForm: closeNewRequestForm); // TODO
    } else if (showSubmittedRequest) {
      return Center(
        child: discussionWidget = Discussion(
          getCurrentRequest: getCurrentRequest,
          currentUser: currentUser,
        ),
      );
    } else {
      return Center(
        child: Text('Select a request',
            style: TextStyle(
                color: Theme.of(context).colorScheme.surface, fontSize: 25)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0.0,
        // Logo
        leading: InkWell(
            onTap: () {},
            child: const Center(
                child: Text(
              'Specon',
              style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
            ))),
        leadingWidth: 110.0,
        title: Text('${currentSubject.code} - ${currentSubject.name}',
            style: TextStyle(
                color: Theme.of(context).colorScheme.surface, fontSize: 20.0)),
        centerTitle: true,
        actions: [
          // Home Button
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
              onTap: () {},
              child: const Icon(
                Icons.home,
                size: 30.0,
              ),
            ),
          ),
          // Switch between student and subject coordinator view Button : TODO: to be removed
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
              onTap: () {
                if (currentUser['userType'] == UserType.subjectCoordinator) {
                  setState(() {
                    currentUser['userType'] = UserType.student;
                  });
                } else {
                  setState(() {
                    currentUser['userType'] = UserType.subjectCoordinator;
                  });
                }
              },
              child: const Icon(
                Icons.sync_outlined,
                size: 30.0,
              ),
            ),
          ),
          // Permission Settings Button
          if (currentUser['userType'] == UserType.subjectCoordinator)
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: InkWell(
                onTap: () {
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (_) => const AsmManager()));
                  //  TODO: HAS TO HAVE A SUBJECT PARAMETER
                },
                child: const Icon(
                  Icons.document_scanner,
                  size: 30.0,
                ),
              ),
            ),
          // Permission Settings Button
          if (currentUser['userType'] == UserType.subjectCoordinator)
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    openPermissionPanel = true;
                  });
                },
                child: const Icon(
                  Icons.admin_panel_settings,
                  size: 30.0,
                ),
              ),
            ),
          // Notification Button
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
              onTap: () {},
              child: const Icon(
                Icons.notifications,
                size: 30.0,
              ),
            ),
          ),
          // Avatar Button
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  if (stopwatch.isRunning &&
                      stopwatch.elapsedMilliseconds < 200) {
                    stopwatch.stop();
                  } else {
                    avatarIsPressed = true;
                  }
                });
              },
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Text('LC',
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .surface)), // TODO: Make LC a variable, so that it changes depending on user's name
              ),
            ),
          ),
        ],
      ),
      body: Stack(children: [
        Row(
          children: [
            // Dashboard column 1
            SizedBox(
              width: 150.0,
              child: Navigation(
                  openNewRequestForm: openNewRequestForm,
                  setCurrentSubject: setCurrentSubject,
                  currentUser: currentUser),
            ),
            VerticalDivider(
              color: Theme.of(context).colorScheme.primary,
              thickness: 3,
              width: 3,
            ),
            // Dashboard column 2
            SizedBox(
              width: 300.0,
              child: requestWidget = Requests(
                getCurrentSubject: getCurrentSubjectCode,
                openSubmittedRequest: openSubmittedRequest,
                currentUser: currentUser,
              ),
            ),
            VerticalDivider(
              color: Theme.of(context).colorScheme.primary,
              thickness: 3,
              width: 3,
            ),
            // Dashboard column 3
            Expanded(
              child: displayThirdColumn(),
            ),
          ],
        ),
        // Menu displayed when avatar is pressed
        if (avatarIsPressed)
          TapRegion(
            onTapOutside: (tap) {
              setState(() {
                avatarIsPressed = false;
                stopwatch.reset();
                stopwatch.start();
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, right: 15.0),
              child: Align(
                alignment: AlignmentDirectional.topEnd,
                child: Container(
                  width: 200,
                  height: 200,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          ),
        if (openPermissionPanel)
          TapRegion(
            onTapOutside: (tap) {
              setState(() {
                openPermissionPanel = false;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0, right: 30.0),
              child: Align(
                alignment: AlignmentDirectional.topEnd,
                child: Container(
                    width: 1680.0,
                    height: 1200.0,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 5.0,
                            color: Theme.of(context).colorScheme.primary)),
                    child: const Permission()),
              ),
            ),
          ),
      ]),
    );
  }
}
