import 'package:flutter/material.dart';

import '../model/request_type.dart';
import '../widgets/request_item.dart';

class AsmManager extends StatefulWidget {
  final Map<String, dynamic>? subject;
  const AsmManager({Key? key, this.subject}) : super(key: key);

  @override
  State<AsmManager> createState() => _AsmManagerState();
}

class _AsmManagerState extends State<AsmManager> {
  final _requestTypesList = RequestType.importTypes();
  final _requestTypeController = TextEditingController();

  List<RequestType> _foundRequestType = [];
  // String? selectedItem; // Declare selectedItem here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        // Change to Column for better control
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 15,
            ),
            child: Row(
              children: [
                BackButton(
                  color: Theme.of(context).colorScheme.surface,
                  onPressed: () {
                    //requestType: ADD TO MAIN DASHBOARD
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Adding assessments to ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      widget.subject != null
                          ? TextSpan(
                              text: '"${widget.subject!['code']}"',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary, // Change the color here
                                fontSize: 30,

                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const TextSpan(
                              text: 'subject name',
                              style: TextStyle(
                                color: Colors.blue, // Change the color here
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    final List<RequestType> importedTypes =
                        RequestType.importTypes();
                    setState(() {
                      _requestTypesList.addAll(importedTypes);
                      _foundRequestType = _requestTypesList;
                    });
                  },
                  child: const Text('Import from Canvas'),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                ElevatedButton(
                  onPressed: () => _showAddNewItemDialog(),
                  child: const Text('Add new'),
                ),
              ],
            ),
          ),
          Expanded(
            // Expanded to take remaining space
            child: Container(
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _foundRequestType.isEmpty
                    ? Center(
                        child: Text(
                          'Nothing to show here',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
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
                      )),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: ElevatedButton(
              onPressed: () {
                if (_foundRequestType.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error: No assessments to import.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  if (widget.subject != null) {
                    widget.subject!['assessments'] = _foundRequestType;
                  }
                  print(widget.subject!['assessments']);
                  Navigator.pop(context);
                }
              },
              child: const Text('Import'),
            ),
          ),
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
                  const Text(
                    'Add New Item',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedItem,
                    onChanged: (value) {
                      setState(() {
                        // Use setState from StatefulBuilder
                        selectedItem = value;
                      });
                    },
                    items: const [
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
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (value) {
                      newItemName = value;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter a new item',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (newItemName.isNotEmpty && selectedItem != null) {
                            _addRequestTypeItem(newItemName, selectedItem!);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Add'),
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
      _requestTypesList.removeWhere((item) => item.id == id);
    });
  }

  void _addRequestTypeItem(String name, String requestType) {
    setState(() {
      _foundRequestType.add(RequestType(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        type: requestType,
      ));
    });
    _requestTypeController.clear();
  }

  void _runFilter(String enteredKeyword) {
    final List<RequestType> results;
    if (enteredKeyword.isEmpty) {
      results = _requestTypesList;
    } else {
      results = _requestTypesList.where((item) {
        return item.name.toLowerCase().contains(enteredKeyword.toLowerCase());
      }).toList();
    }
    setState(() => _foundRequestType = results);
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.secondary,
            size: 20,
          ),
          prefixIconConstraints: const BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
    );
  }
}
