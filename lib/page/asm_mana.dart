import 'package:flutter/material.dart';

import '../model/request_type.dart';
import '../constants/colors.dart';
import '../widgets/request_item.dart';

class AsmManager extends StatefulWidget {
  AsmManager({Key? key}) : super(key: key);

  @override
  State<AsmManager> createState() => _AsmManagerState();
}

class _AsmManagerState extends State<AsmManager> {
  final requestTypesList = RequestType.importTypes();
  List<RequestType> _foundRequestType = [];
  final _requestTypeController = TextEditingController();
  final _subjectNameController = TextEditingController(); // Add this controller

  // String? selectedItem; // Declare selectedItem here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tertiaryColor,
      appBar: _buildAppBar(),
      body: Column(
        // Change to Column for better control
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: Row(
              children: [
                Text(
                  'Imported from Canvas',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    // Call the importTypes() function
                    List<RequestType> importedTypes =
                        await RequestType.importTypes();

                    // Update the requestTypesList and _foundrequestType with imported data
                    setState(() {
                      requestTypesList.addAll(importedTypes);
                      _foundRequestType = requestTypesList;
                      _subjectNameController.text =
                          'Comp20008'; // Update the field value
                    });
                  },
                  child: Text("Import from Canvas"),
                ),
                SizedBox(
                  width: 10.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    _showAddNewItemDialog();
                  },
                  child: Text("Add new"),
                ),
              ],
            ),
          ),
          TextFormField(
            style: TextStyle(color: textColor),
            controller: _subjectNameController, // Bind the controller
            cursorColor: textColor,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: textColor,
                  width: 0.5,
                ),
              ),
              labelText: "Subject Name",
              labelStyle: TextStyle(color: textColor, fontSize: 18),
              floatingLabelStyle: TextStyle(color: textColor, fontSize: 22),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFD78521),
                  width: 1,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Expanded(
            // Expanded to take remaining space
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _foundRequestType.isEmpty
                    ? Center(
                        child: Text(
                          "Nothing to show here",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ReorderableListView(
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item = _foundRequestType.removeAt(oldIndex);
                            _foundRequestType.insert(newIndex, item);
                          });
                        },
                        children:
                            _foundRequestType.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;

                          return RequestTypeItem(
                            // Use RequestTypeItem widget here
                            key: ValueKey(index),
                            requestType: item,
                            onDeleteItem: _deleteRequestTypeItem,
                          );
                        }).toList(),
                      )

                // ListView.builder(
                //     itemCount: _foundrequestType.length,
                //     itemBuilder: (BuildContext context, int index) {
                //       return RequestTypeItem(
                //         requestType: _foundrequestType.reversed.toList()[index],
                //         onDeleteItem: _deleterequestTypeItem,
                //       );
                //     },
                //   ),
                ),
          ),
          Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              child: ElevatedButton(
                  onPressed: () {
                    //requestType: ADD TO MAIN DASHBOARD
                    Navigator.pushReplacementNamed(context, "/home");
                  },
                  child: Text("import"))),
        ],
      ),
    );
  }

  Future<void> _showAddNewItemDialog() async {
    String newItemName = ''; // Declare newItemName variable
    String? selectedItem; // Move the selectedItem declaration here

    // Remove the declaration of selectedItem here

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Wrap the content in StatefulBuilder
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add New Item',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedItem,
                    onChanged: (value) {
                      setState(() {
                        // Use setState from StatefulBuilder
                        selectedItem = value;
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'assignment extension',
                        child: Text('Assignment Extension'),
                      ),
                      DropdownMenuItem(
                        value: 'participation waiver',
                        child: Text('Participation Waiver'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    onChanged: (value) {
                      newItemName = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter a new item',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (newItemName.isNotEmpty && selectedItem != null) {
                            _addRequestTypeItem(newItemName, selectedItem!);
                            Navigator.pop(context);
                          }
                        },
                        child: Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _deleteRequestTypeItem(String id) {
    setState(() {
      requestTypesList.removeWhere((item) => item.id == id);
    });
  }

  void _addRequestTypeItem(String name, String requestType) {
    setState(() {
      requestTypesList.add(RequestType(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        type: requestType,
      ));
    });
    _requestTypeController.clear();
  }

  void _runFilter(String enteredKeyword) {
    List<RequestType> results = [];
    if (enteredKeyword.isEmpty) {
      results = requestTypesList;
    } else {
      results = requestTypesList
          .where((item) =>
              item.name!.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundRequestType = results;
    });
  }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdBGColor,
      elevation: 0,
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Icon(
          Icons.menu,
          color: tdBlack,
          size: 30,
        ),
        Container(
          height: 40,
          width: 40,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset('assets/images/avatar.jpeg'),
          ),
        ),
      ]),
    );
  }
}
