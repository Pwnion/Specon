/// The main page for an authenticated user.
///
/// Content changes based on the [UserType] that is authenticated.

import 'package:flutter/material.dart';
import 'package:specon/page/dashboard/navigation.dart';

import '../user_type.dart';
import 'dashboard/requests.dart';
import 'package:specon/form.dart';

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

  final topBarColor = const Color(0xFF385F71);
  final avatarBackgroundColor = const Color(0xFFD78521);
  final mainBodyColor = const Color(0xFF333333);
  final menuColor = const Color(0xFFD4D4D4);
  final dividerColor = Colors.white;
  final stopwatch = Stopwatch();
  String currentSubject = '';
  bool avatarIsPressed = false;
  bool newRequest = false;
  String userType = 'student';
  Widget? requestWidget;

  String getCurrentSubject() {
    return currentSubject;
  }

  void openNewRequestForm() {
    setState(() {
      newRequest = true;
    });
  }

  void closeNewRequestForm() {
    setState(() {
      newRequest = false;
    });
  }

  void setCurrentSubject(String subject) {
    setState(() {
      currentSubject = subject;
      requestWidget;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(

      appBar: AppBar(
        backgroundColor: topBarColor,
        elevation: 0.0,

        leading: InkWell(
          onTap: () {},
          child: const Center(
            child: Text(
              'Specon',
              style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
            )
          )
        ),

        leadingWidth: 110.0,

        title: Text(currentSubject, style: const TextStyle(color: Colors.white,fontSize: 20.0,)),
        centerTitle: true,

        actions: [

          // Home Button
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
              onTap: () {},
              child: const Icon(Icons.home, size: 30.0,),
            ),
          ),

          // Notification Button
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
              onTap: () {},
              child: const Icon(Icons.notifications, size: 30.0,),
            ),
          ),

          // Avatar Button
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: InkWell(
              onTap: () {
                setState(() {

                  if (stopwatch.isRunning && stopwatch.elapsedMilliseconds < 200) {
                    stopwatch.stop();
                  } else {
                    avatarIsPressed = true;
                  }
                });
              },
              child: CircleAvatar(
                backgroundColor: avatarBackgroundColor,
                child: const Text('LC', style: TextStyle(color: Colors.white)), // TODO: Make LC a variable, so that it changes depending on user's name
              ),
            ),
          ),
        ],

      ),

      body: Stack(
        children: [

          Row(
          children: [

            // Dashboard column 1
            Expanded(
                flex: 1,
                child: Navigation(openNewRequestForm: openNewRequestForm, setCurrentSubject: setCurrentSubject, userType: userType)
            ),

            VerticalDivider(
              color: dividerColor,
              thickness: 3,
              width: 3,
            ),

            // Dashboard column 2
            Expanded(
                flex: 2,
                child: requestWidget = Requests(getCurrentSubject: getCurrentSubject),
            ),

            VerticalDivider(
              color: dividerColor,
              thickness: 3,
              width: 3,
            ),

            // Dashboard column 3
            Expanded(
              flex: 5,
              child: newRequest ? SpeconForm(closeNewRequestForm: closeNewRequestForm) : Container()
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
                    color: menuColor,
                  ),
                ),
              ),
          ),
        ]
      ),
    );
  }
}