import 'package:flutter/material.dart';
import '../mock_data.dart';

class Permission extends StatefulWidget {
  const Permission({super.key});

  @override
  State<Permission> createState() => _PermissionState();
}

class _PermissionState extends State<Permission> {
  final _scrollController = ScrollController();
  
  var inEditMode = false;
  var editButtonText = 'Edit';

  static final List<String> requestTypes = ['Extension', 'Regrade', 'Waiver', 'Others'];
  List permissionGroups = [
    {'name': 'Head Tutor',
     'priority': 1,
     'users': ['Alex'],
     'assessments': {
       'Project 1': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': true},
       'Project 2': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': true},
       'Project 3': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': true},
       'Assignment 1': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': true},
       'Assignment 2': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': true},
       'Mid Semester Test': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': true},
       'Final Exam': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': true},
       'Others': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': true},
      }
    },
    {'name': 'Tutor',
     'priority': 2,
     'users': ['Lucas'],
     'assessments': {
       'Project 1': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': false},
       'Project 2': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': false},
       'Project 3': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': false},
       'Assignment 1': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': false},
       'Assignment 2': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': false},
       'Mid Semester Test': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': false},
       'Final Exam': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': false},
       'Others': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': false},
      }
    },
    {'name': 'Lecturer',
     'priority': 3,
     'users': ['Tawfiq'],
     'assessments': {
        'Project 1': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': true},
        'Project 2': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': true},
        'Project 3': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': true},
        'Assignment 1': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': true},
        'Assignment 2': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': true},
        'Mid Semester Test': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': true},
        'Final Exam': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': true},
        'Others': {'Extension': true, 'Regrade': true, 'Waiver': true, 'Others': true}
      }
    }
  ];

  List<Widget> buildUserColumn(final List users) {
    return users.map((user) => Text(user)).toList();
  }

  List<Widget> buildCheckboxRow(Map<String, bool> requestTypePermissions) {

    List<Widget> row = [];
    const Widget greenTick = Icon(Icons.check_box_rounded, color: Colors.green);
    const Widget redCross = Icon(Icons.close, color: Colors.red);

    for(final requestType in requestTypes) {

      // Not in Edit Mode
      if (!inEditMode) {
        if (requestTypePermissions[requestType]!) {
          row.add(const SizedBox(width: 70.0, child: greenTick));
        }
        else {
          row.add(const SizedBox(width: 70.0, child: redCross));
        }
      }

      // In edit mode
      else {
        row.add(
          SizedBox(
            width: 70.0,
            child: Checkbox(
              value: requestTypePermissions[requestType],
              checkColor: Theme.of(context).colorScheme.surface,
              onChanged: (bool? value) {
                setState(() {
                  requestTypePermissions[requestType] = value!;
                });
              },
            ),
          ),
        );
      }
    }
    return row;
  }

  Widget buildPermissionColumn(Map<String, dynamic> assessments){
    final List<Widget> requestTypeHeaders = [];
    final List<Widget> rows = [];

    requestTypeHeaders.add(const SizedBox(width:150.0));

    for (final requestType in requestTypes){
      requestTypeHeaders.add(
        SizedBox(
          width: 70.0,
          child: Center(
            child: Text(
              requestType,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        )
      );
    }

    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...requestTypeHeaders
        ],
      )
    );

    if(!inEditMode){
      rows.add(const SizedBox(height: 4.2));
    }

    for(final assessment in assessments.keys.toList()){

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width:150.0,
              child: Center(
                child: Text(
                  assessment,
                  style: const TextStyle(fontWeight: FontWeight.bold)
                )
              )
            ),

            ...buildCheckboxRow(assessments[assessment]),
          ],
        )
      );

      if(!inEditMode){
        rows.add(const SizedBox(height: 7.9));
      }

    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...rows
      ]
    );
  }

  Widget buildGroupColumn(String userGroupName) {

    final controller = TextEditingController(text: userGroupName);
    var newGroupName = userGroupName;

    if(inEditMode) {
      return Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: EditableText(
          forceLine: false,
          autofocus: false,
          controller: controller,
          focusNode: FocusNode(),
          style: const TextStyle(color: Colors.black),
          textAlign: TextAlign.center,
          cursorColor: Colors.red,
          backgroundCursorColor: Colors.red,
          onChanged: (value) {
            newGroupName = value;
          },
          onTapOutside: (pointer) {
            setState(() {
              for (final permissionGroup in permissionGroups) {
                if (permissionGroup['name'] == userGroupName){
                  permissionGroup['name'] = newGroupName;
                }
              }
            });
          }, // TODO: Can be made tidier
        ),
      );
    }
    else {
      return Text(userGroupName);
    }
  }

  Widget buildPermissionRows() {
    return Flexible(
      child: Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: ReorderableListView.builder(
          scrollController: _scrollController,
          itemCount: permissionGroups.length,
          onReorder: (oldIndex, newIndex) {

            final len = permissionGroups.length;

            if (newIndex > len) newIndex = len;
            if (oldIndex < newIndex) newIndex--;

            final permissionGroup = permissionGroups[oldIndex];

            setState(() {
              permissionGroups.remove(permissionGroup);
              permissionGroups.insert(newIndex, permissionGroup);
            });
            // TODO: Create function to update new priorities for each item
            // TODO: Change priority on DB
          },
          itemBuilder: (context, index) => Container(
            key: ValueKey(permissionGroups[index]['priority']),
            color: Theme.of(context).colorScheme.surface,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Group
                  Container(
                    width: 200.0,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Theme.of(context).colorScheme.primary),
                        left: BorderSide(color: Theme.of(context).colorScheme.primary),
                      )
                    ),
                    child: Center(
                        child: buildGroupColumn(permissionGroups[index]['name']),
                    ),
                  ),
                  // Users
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Theme.of(context).colorScheme.primary),
                          left: BorderSide(color: Theme.of(context).colorScheme.primary),
                          right: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 5.0),
                          Expanded(
                            child: Column(
                              children: [
                                ...buildUserColumn(permissionGroups[index]['users'])
                              ]
                            )
                          ),
                          const SizedBox(height: 5.0),
                          if (inEditMode)
                          MaterialButton(
                            color: Theme.of(context).colorScheme.surface,
                            height: 1.0,
                            minWidth: 1.0,
                            onPressed: () {
                              setState(() {
                                permissionGroups[index]['users'].add('Bob');
                              });
                            },
                            shape: const CircleBorder(),
                            child: const Text('+'),
                          )
                        ],
                      ),
                    ),
                  ),
                  // Permissions
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Theme.of(context).colorScheme.primary),
                          right: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      child: Center(child: buildPermissionColumn(permissionGroups[index]['assessments'])),
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                      permissionGroups.add(permGroup);
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
            // Headers
            Container(
              height: 40.0,
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                children: [
                  // Group
                  Container(
                    width: 200.0,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Theme.of(context).colorScheme.primary),
                        left: BorderSide(color: Theme.of(context).colorScheme.primary),
                        top: BorderSide(color: Theme.of(context).colorScheme.primary),
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
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Theme.of(context).colorScheme.primary),
                          right: BorderSide(color: Theme.of(context).colorScheme.primary),
                          top: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      child: const Center(child: Text('Permissions', style: TextStyle(fontWeight: FontWeight.bold)))
                    ),
                  ),
                ],
              ),
            ),
            // Rows for each permission groups
            buildPermissionRows(),
          ],
        ),
      )
    );
  }
}