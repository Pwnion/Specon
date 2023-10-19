/// Page where subject coordinators can configure user group's permissions
/// to view various types of requests
///
/// Author: Zhi Xiang Chan (Lucas)

import 'package:flutter/material.dart';
import 'package:specon/models/subject_model.dart';
import 'package:specon/page/db.dart';

class Permission extends StatefulWidget {

  final SubjectModel currentSubject;

  const Permission(
    {Key? key, required this.currentSubject}
  ) : super(key: key);

  @override
  State<Permission> createState() => _PermissionState();
}

class _PermissionState extends State<Permission> {
  final _scrollController = ScrollController();
  final _addUserScrollController = ScrollController();
  static final _db = DataBase();
  
  var inEditMode = false;
  var editButtonText = 'Edit';

  static final List<String> requestTypes = ['Extension', 'Regrade', 'Waiver', 'Others'];
  static final List<String> canvasUser = ['Tawfiq', 'Alex', 'Aden', 'Brian', 'Drey', 'Jeremy', 'Lucas', 'Geela']; // TODO: Should get from API
  List<Map<String, dynamic>> permissionGroups = [];
  List<Map<String, dynamic>> temporaryPermissionGroups = [];
  List<String> temporaryUserList = [];
  bool fetchingFromDB = true;

  /// Function that builds the group column (Column 2)
  List<Widget> buildUserColumn(final List users) {
    return users.map((user) => Text(user)).toList();
  }

  /// Function that builds the checkboxes in column 3
  List<Widget> buildCheckboxRow(Map<String, bool> requestTypePermissions) {

    List<Widget> row = [];
    const Widget greenTick = Icon(Icons.check_box_rounded, color: Colors.green);
    const Widget redCross = Icon(Icons.close, color: Colors.red);

    for(final requestType in requestTypes) {

      // Not in Edit Mode
      if (!inEditMode) {
        if (requestTypePermissions[requestType]!) {
          row.add(const SizedBox(width: 70.0, height: 35.0, child: greenTick));
        }
        else {
          row.add(const SizedBox(width: 70.0, height: 35.0, child: redCross));
        }
      }
      // In edit mode
      else {
        row.add(
          SizedBox(
            width: 70.0,
            height: 35.0,
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

  /// Function that either selects all or deselect all checkboxes of a group
  void selectOrDeselectAll(Map<String, dynamic> assessments, bool changeTo) {

    for(final assessment in assessments.keys.toList()){
      for(final requestType in requestTypes){
        setState(() {
          assessments[assessment][requestType] = changeTo;
        });
      }
    }
  }

  /// Function that builds the permission column (Column 3)
  Widget buildPermissionColumn(Map<String, dynamic> assessments) {
    final List<Widget> requestTypeHeaders = [];
    final List<Widget> rows = [];

    if (!inEditMode) {
      requestTypeHeaders.add(const SizedBox(width: 220.0, height: 30.0));
    } else {
      requestTypeHeaders.add(
        SizedBox(
          width: 220.0,
          height: 30.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 90.0,
                height: 30.0,
                child: FractionallySizedBox(
                  heightFactor: 0.7,
                  widthFactor: 1,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary
                    ),
                    onPressed: () {
                      selectOrDeselectAll(assessments, true);
                    },
                    child: Text(
                      'Select All',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface
                      )
                    )
                  ),
                ),
              ),
              SizedBox(
                width: 110.0,
                height: 30.0,
                child: FractionallySizedBox(
                  heightFactor: 0.7,
                  widthFactor: 1,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary
                    ),
                    onPressed: () {
                      selectOrDeselectAll(assessments, false);
                    },
                    child: Text(
                      'Deselect All',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface
                      )
                    )
                  ),
                ),
              )
            ]
          )
        )
      );
    }

    for (final requestType in requestTypes){
      requestTypeHeaders.add(
        SizedBox(
          width: 70.0,
          height: 30.0,
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

    for(final assessment in assessments.keys.toList()){
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 220.0,
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
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...rows
      ]
    );
  }

  /// Function that builds the group column (Column 1)
  Widget buildGroupColumn(String userGroupName) {

    final controller = TextEditingController(text: userGroupName);
    var newGroupName = userGroupName;

    // In edit mode
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
              for (final permissionGroup in temporaryPermissionGroups) {
                if (permissionGroup['name'] == userGroupName){
                  permissionGroup['name'] = newGroupName;
                }
              }
            });
          }, // TODO: Can be made tidier
        ),
      );
    }
    // Not in edit mode
    else {
      return Text(userGroupName);
    }
  }

  /// Function that builds the user management dialog for a user group
  Future<List<String>?> buildUserManagementDialog(int currentGroupIndex) {

    if(temporaryUserList.isEmpty){
      setState(() {
        temporaryUserList = List.from(temporaryPermissionGroups[currentGroupIndex]['users']);
      });
    }

    return showDialog<List<String>>(
      barrierDismissible: false,
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setState) => AlertDialog(
          title: Text(
            "Edit ${temporaryPermissionGroups[currentGroupIndex]['name']}'s users [${widget.currentSubject.code}]",
            style: TextStyle(color: Theme.of(context).colorScheme.surface)
          ),
          content: SizedBox(
            width: 500,
            height: 500,
            child: SingleChildScrollView(
              controller: _addUserScrollController,
              child: ListView.builder(
                controller: _addUserScrollController,
                itemCount: canvasUser.length,
                shrinkWrap: true,
                itemBuilder: (_, index) => ListTile(
                  title: Text(canvasUser[index], style: TextStyle(color: Theme.of(context).colorScheme.surface)),
                  subtitle: Text('Role on canvas : ???', style: TextStyle(color: Theme.of(context).colorScheme.surface)), // TODO:
                  trailing: temporaryUserList.contains(canvasUser[index])
                    ? IconButton(
                      icon: Icon(Icons.check_circle, color: Colors.green[700]),
                      onPressed: () {
                        setState(() {
                          temporaryUserList.remove(canvasUser[index]);
                        });
                      }
                    )
                  : IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        temporaryUserList.add(canvasUser[index]);
                      });
                    }
                  )
                )
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, temporaryPermissionGroups[currentGroupIndex]['users']);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, temporaryUserList);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  /// Function that builds rows for each permission group
  Widget buildPermissionRows() {
    return Flexible(
      child: Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: ReorderableListView.builder(
          scrollController: _scrollController,
          itemCount: temporaryPermissionGroups.length,
          onReorder: (oldIndex, newIndex) {

            final len = temporaryPermissionGroups.length;

            if (newIndex > len) newIndex = len;
            if (oldIndex < newIndex) newIndex--;

            final permissionGroup = temporaryPermissionGroups[oldIndex];

            setState(() {
              temporaryPermissionGroups.remove(permissionGroup);
              temporaryPermissionGroups.insert(newIndex, permissionGroup);
            });
            // TODO: Create function to update new priorities for each item
            // TODO: Change priority on DB
          },
          itemBuilder: (context, index) => Container(
            key: ValueKey(temporaryPermissionGroups[index]['priority']),
            color: Theme.of(context).colorScheme.surface,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Groups
                  Container(
                    width: 200.0,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Theme.of(context).colorScheme.primary),
                        left: BorderSide(color: Theme.of(context).colorScheme.primary),
                      )
                    ),
                    child: Center(
                        child: buildGroupColumn(temporaryPermissionGroups[index]['name']),
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
                                ...buildUserColumn(temporaryPermissionGroups[index]['users'])
                              ]
                            )
                          ),
                          const SizedBox(height: 5.0),

                          // Plus button
                          if (inEditMode)
                          MaterialButton(
                            color: Theme.of(context).colorScheme.surface,
                            height: 1.0,
                            minWidth: 1.0,
                            onPressed: () {
                              buildUserManagementDialog(index).then((value) {
                                setState((){
                                  temporaryPermissionGroups[index]['users'] = value;
                                  temporaryUserList = [];
                                });
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
                      child: Center(child: buildPermissionColumn(temporaryPermissionGroups[index]['assessments'])),
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

  /// Function that deep copies a list of permission groups to another list
  List<Map<String, dynamic>> deepCopy(List<Map<String, dynamic>> copyFrom) {

    List<Map<String, dynamic>> copyTo = [];

    for(final group in copyFrom){

      Map<String, Map<String, bool>> assessments = {};

      for(final assessment in group['assessments'].keys.toList()){
        assessments[assessment] = {...group['assessments'][assessment]};
      }

      copyTo.add({
        'name': group['name'],
        'priority': group['priority'],
        'users': List.from(group['users']),
        'assessments': assessments
      });
    }

    return copyTo;
  }

  @override
  void initState() {

    _db.getPermissionGroups(widget.currentSubject).then((value) {
      setState(() {
        permissionGroups = deepCopy(value);
        temporaryPermissionGroups = deepCopy(permissionGroups);
        fetchingFromDB = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Not fetching permission from database
    if(!fetchingFromDB) {
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
                  const SizedBox(width: 10.0),
                  // Edit/Save Button
                  ElevatedButton(
                    onPressed: () {
                      setState(() {

                        // If in edit mode, save the changes
                        if(inEditMode){
                          permissionGroups = deepCopy(temporaryPermissionGroups);
                          // TODO: Update changes on DB
                        }
                        // If not in edit mode, copy original list
                        else {
                          temporaryPermissionGroups = deepCopy(permissionGroups);
                        }

                        inEditMode = !inEditMode;
                        editButtonText = inEditMode ? 'Save' : 'Edit';
                      });
                    },
                    child: Text(editButtonText),
                  ),
                  const SizedBox(width: 10.0),
                  // Cancel Button
                  if(inEditMode)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        inEditMode = false;
                        editButtonText = 'Edit';

                        // Don't save the changes
                        temporaryPermissionGroups = deepCopy(permissionGroups);
                      });
                    },
                    child: const Text('Cancel')
                  ),
                  const SizedBox(width: 10.0),
                  // Add new group button
                  if(inEditMode)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // temporaryPermissionGroups.add();
                      });
                    },
                    child: const Text('Add new group')
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
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.primary
                          ),
                          left: BorderSide(
                            color: Theme.of(context).colorScheme.primary
                          ),
                          top: BorderSide(
                            color: Theme.of(context).colorScheme.primary
                          )
                        )
                      ),
                      child: const Center(
                        child: Text(
                          'Groups',
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          )
                        )
                      )
                    ),
                    // Users
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1)
                        ),
                        child: const Center(
                          child: Text(
                            'Users',
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            )
                          )
                        )
                      ),
                    ),
                    // Permissions
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).colorScheme.primary
                            ),
                            right: BorderSide(
                              color: Theme.of(context).colorScheme.primary
                            ),
                            top: BorderSide(
                              color: Theme.of(context).colorScheme.primary
                            )
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Permissions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            )
                          )
                        )
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
    // Fetching permission from database
    else {
      return const SizedBox(
        height: 100.0,
        width: 100.0,
        child: Center(child: CircularProgressIndicator()),
      );
    }
  }
}