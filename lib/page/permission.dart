import 'package:flutter/material.dart';
import 'package:specon/backend.dart';
import 'package:specon/user_type.dart';

class Permission extends StatefulWidget {
  const Permission({super.key});

  @override
  State<Permission> createState() => _PermissionState();
}

class _PermissionState extends State<Permission> {

  List<String> assessments = BackEnd().getAssessments('subjectID');
  final _scrollController3 = ScrollController();
  bool inEditMode = false;
  String editButtonText = 'Edit';

  List users = [
    {'userID': 1, 'name': 'Alex', 'userType': UserType.subjectCoordinator},
    {'userID': 2, 'name': 'Tawfiq', 'userType': UserType.subjectCoordinator},
    {'userID': 3, 'name': 'Aden', 'userType': UserType.tutor},
    {'userID': 4, 'name': 'Brian', 'userType': UserType.tutor},
    {'userID': 5, 'name': 'Drey', 'userType': UserType.tutor},
    {'userID': 6, 'name': 'Jeremy', 'userType': UserType.tutor},
    {'userID': 7, 'name': 'Lucas', 'userType': UserType.tutor},
    {'userID': 8, 'name': 'Maddie', 'userType': UserType.student},
    {'userID': 9, 'name': 'Nathan', 'userType': UserType.student},
    {'userID': 10, 'name': 'Ollie', 'userType': UserType.student},
  ];

  List permissionGroups = [
    {'group': 'Head Tutor', 'users': ['Alex'], 'permissions': ['Final Exam']},
    {'group': 'Tutor', 'users': ['Lucas'], 'permissions': ['Participation Waiver']},
    {'group': 'Lecturer', 'users': ['Tawfiq'], 'permissions': ['Due date extension']},
  ];

  List typesOfPermissions = [
    "Project 1",
    "Project 2",
    "Final Exam",
    "Mid Semester Exam",
    "Participation Waiver",
    "Due date extension",
    "Change tutorial",
    "Others",
  ];

  List<Widget> buildUserColumns(List users) {
    
    List<Widget> userColumns = [];
    
    for(var user in users) {

      userColumns.add(Text(user));
      
    }

    return userColumns;
  }

  List<Widget> buildPermissionCheckbox(List permissions){

    List<Widget> permissionWidgets = [];
    Widget greenTick = const Icon(Icons.check_box_rounded, color: Colors.green);
    Widget redCross = const Icon(Icons.close, color: Colors.red);

    for(var permission in typesOfPermissions) {

      if(!inEditMode) {
        if (permissions.contains(permission)) {
          permissionWidgets.add(Row(children: [const SizedBox(width: 200), Text(permission), greenTick]));
        }else{
          permissionWidgets.add(Row(children: [const SizedBox(width: 200), Text(permission), redCross]));
        }
      } else{

        bool isChecked = permissions.contains(permission) ? true : false;

        permissionWidgets.add(
          Row(
            children: [
              const SizedBox(width: 200),
              Text(permission),
              Checkbox(
                value: isChecked,
                checkColor: Colors.white,
                onChanged: (bool? value) {
                  setState(() {

                    isChecked = value!;

                    // If checked and permission not in list, add it
                    if (isChecked && !permissions.contains(permission)) {
                      permissions.add(permission);

                    } else if (!isChecked) {
                      permissions.remove(permission);
                    }
                  });
                },
              ),
            ]
          )
        );
      }
    }

    return permissionWidgets;
  }

  Widget buildPermissionRows() {

    return Flexible(
      child: Scrollbar(
        thumbVisibility: true,
        controller: _scrollController3,
        child: ListView.builder(
          itemCount: permissionGroups.length,
          controller: _scrollController3,
          itemBuilder: (context, index) => Container(
            color: Colors.white38,
            child: IntrinsicHeight(
              child: Row(
                children: [

                  // Group
                  Container(
                    width: 200.0,
                    decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black),
                          left: BorderSide(color: Colors.black),
                        )
                    ),
                    child: Center(child: Text(permissionGroups[index]['group'])),
                  ),

                  // Users
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black),
                          left: BorderSide(color: Colors.black),
                          right: BorderSide(color: Colors.black),
                        ),
                      ),
                      child: Column(
                        children: [

                          const SizedBox(height: 5.0),

                          Expanded(child: Column(children: [...buildUserColumns(permissionGroups[index]['users'])],)),

                          const SizedBox(height: 5.0),

                          if (inEditMode)
                          MaterialButton(
                            color: Colors.grey,
                            height: 1.0,
                            minWidth: 1.0,
                            onPressed: () {
                              setState(() {
                                permissionGroups[index]['users'].add('Bob');
                              });
                            },
                            shape: const CircleBorder(),
                            child: const Text("+"),
                          )
                        ],
                      ),
                    ),
                  ),

                  // Permissions
                  Expanded(
                    flex: 2,
                    child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.black),
                            right: BorderSide(color: Colors.black),
                          ),
                        ),
                      child: Column(
                        children: [...buildPermissionCheckbox(permissionGroups[index]['permissions'])],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        leadingWidth: 200.0,
        title: const Text('Permission Settings'),
      ),

      body: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Buttons
            Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        permissionGroups.add({'group': 'Lecturer', 'users': ['Tawfiq'], 'permissions': ['Extension']});
                      });
                    },
                    child: const Text('Add new group')
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        editButtonText = inEditMode ? 'Edit' : 'Save';
                        inEditMode = !inEditMode;
                      });
                    },
                    child: Text(editButtonText),
                ),
              ],
            ),

            const SizedBox(height: 10.0),

            Container(
              height: 40.0,
              color: Colors.white,
              child: Row(
                children: [

                  // Group
                  Container(
                    width: 200.0,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black),
                        left: BorderSide(color: Colors.black),
                        top: BorderSide(color: Colors.black),
                      )
                    ),
                    child: const Center(child: Text('Groups', style: TextStyle(fontWeight: FontWeight.bold))),
                  ),

                  // Users
                  Expanded(
                    flex: 1,
                    child: Container(
                        decoration: BoxDecoration(border: Border.all(width: 1)),
                        child: const Center(child: Text('Users', style: TextStyle(fontWeight: FontWeight.bold)))
                    ),
                  ),

                  // Permissions
                  Expanded(
                    flex: 2,
                    child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.black),
                            right: BorderSide(color: Colors.black),
                            top: BorderSide(color: Colors.black),
                          ),
                        ),
                        child: const Center(child: Text('Permissions', style: TextStyle(fontWeight: FontWeight.bold)))
                    ),
                  ),
                ],
              ),
            ),

            buildPermissionRows(),
          ],
        ),
      )
    );
  }
}