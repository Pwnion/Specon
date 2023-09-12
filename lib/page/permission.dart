import 'package:flutter/material.dart';
import 'package:specon/backend.dart';
import '../mock_data.dart';

class Permission extends StatefulWidget {
  const Permission({super.key});

  @override
  State<Permission> createState() => _PermissionState();
}

class _PermissionState extends State<Permission> {
  final List<String> assessments = BackEnd().getAssessments('subjectID');
  final _scrollController = ScrollController();
  
  var inEditMode = false;
  var editButtonText = 'Edit';
  
  List<Widget> buildUserColumns(final List users) {
    return users.map((user) => Text(user)).toList();
  }

  List<Widget> buildPermissionCheckbox(List permissions){
    final List<Widget> permissionWidgets = [];
    Widget greenTick = const Icon(Icons.check_box_rounded, color: Colors.green);
    const Widget redCross = Icon(Icons.close, color: Colors.red);

    for(final permission in typesOfPermissions) {
      if(!inEditMode) {
        if(permissions.contains(permission)) {
          permissionWidgets.add(Row(children: [const SizedBox(width: 200), Text(permission), greenTick]));
        } else {
          permissionWidgets.add(Row(children: [const SizedBox(width: 200), Text(permission), redCross]));
        }
      } else{
        var isChecked = permissions.contains(permission) ? true : false;
        permissionWidgets.add(
          Row(
            children: [
              const SizedBox(width: 200),
              Text(permission),
              Checkbox(
                value: isChecked,
                checkColor: Theme.of(context).colorScheme.surface,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value!;
                    // If checked and permission not in list, add it
                    if(isChecked && !permissions.contains(permission)) {
                      permissions.add(permission);
                    } else if(!isChecked) {
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
        controller: _scrollController,
        child: ListView.builder(
          itemCount: permissionGroups.length,
          controller: _scrollController,
          itemBuilder: (context, index) => Container(
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
                    child: Center(child: Text(permissionGroups[index]['group'])),
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
                          Expanded(child: Column(children: [...buildUserColumns(permissionGroups[index]['users'])],)),
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
            buildPermissionRows(),
          ],
        ),
      )
    );
  }
}