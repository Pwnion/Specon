/// The main page for an authenticated user.
///
/// Content changes based on the [UserType] that is authenticated.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../user_type.dart';
import 'dashboard/requests.dart';
import 'dashboard/navigation.dart';
import 'package:specon/form.dart';
import 'db.dart';

class Dashboard extends StatefulWidget {
  final UserType userType;

  const Dashboard({Key? key, required this.userType}) : super(key: key);

  @override
  State<Dashboard> createState() => DashboardState();
}

// changed to singleton class for temporary fix
class DashboardState extends State<Dashboard> {
  // singleton stuff--------------------------------------------
  // static final DashboardState _instance = DashboardState._internal();
  // factory DashboardState() {
  //   return _instance;
  // }
  // DashboardState._internal();
  // end of singleton stuff--------------------------------------

  //final requestButtonColor = const Color(0xFFDF6C00);
  final topBarColor = const Color(0xFF385F71);
  final avatarBackgroundColor = const Color(0xFFD78521);
  final mainBodyColor = const Color(0xFF333333);
  final menuColor = const Color(0xFFD4D4D4);
  final dividerColor = Colors.white;
  final stopwatch = Stopwatch();
  String currentSubject = '';
  bool avatarIsPressed = false;
  bool newRequest = false;
  //String userType = 'student';

  // setters for temporary fix, can't use (can't pass instance?)
  setCurrentSubject(String currentSubject) {
    // setState(() {
    //   this.currentSubject = currentSubject;
    // });
  }
  setNewRequest(bool newRequest) {
    // setState(() {
    //   this.newRequest = newRequest;
    // });
  }

  void closeNewRequestForm() {
    setState(() {
      newRequest = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            ))),
        leadingWidth: 110.0,
        title: Text(currentSubject,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            )),
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
                backgroundColor: avatarBackgroundColor,
                child: const Text('LC',
                    style: TextStyle(
                        color: Colors
                            .white)), // TODO: Make LC a variable, so that it changes depending on user's name
              ),
            ),
          ),
        ],
      ),
      body: Stack(children: [
        Row(
          children: [
            // Dashboard column 1
            const Expanded(flex: 1, child: Navigation()),

            VerticalDivider(
              color: dividerColor,
              thickness: 3,
              width: 3,
            ),

            // Dashboard column 2
            const Expanded(flex: 2, child: Requests()),

            VerticalDivider(
              color: dividerColor,
              thickness: 3,
              width: 3,
            ),

            // Dashboard column 3, make submit form always open for now
            Expanded(
                flex: 4,
                child: SpeconForm(closeNewRequestForm: closeNewRequestForm)
                //child: newRequest ? SpeconForm(closeNewRequestForm: closeNewRequestForm) : Container()
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
      ]),
    );
  }
}
