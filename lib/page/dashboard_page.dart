/// The main page for an authenticated user.
///
/// Content changes based on the [UserType] that is authenticated.

import 'package:flutter/material.dart';

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

  final requestButtonColor = const Color(0xFFDF6C00);
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
              onPressed: () {
                setState(() {
                  currentSubject = subject;
                });
              },
              child: Text(subject),
          ),
        ),
      );
    }
    return subjectWidgets;
  }

  void closeNewRequestForm() {
    setState(() {
      newRequest = false;
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    // Display new request button only if user is a student
                    if (userType == 'student')
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ElevatedButton (
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(requestButtonColor)),
                        onPressed: () {
                          setState(() {
                            newRequest = true;
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
                ),
            ),

            VerticalDivider(
              color: dividerColor,
              thickness: 3,
              width: 3,
            ),

            // Dashboard column 2
            const Expanded(
                flex: 2,
                child: Requests()
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