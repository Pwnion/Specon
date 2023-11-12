/// A stateless singular widget for representing a request type item.
///
/// This widget displays information about a [RequestType] and provides options
/// to edit or delete it.
///
/// Author: Drey Nguyen
import 'package:flutter/material.dart';
import '../models/request_type.dart';

class RequestTypeItem extends StatelessWidget {
  final RequestType requestType;
  final Function onDeleteItem;
  final Function(String, String) onUpdateName; // real time update name

  /// Constructor for [RequestTypeItem].
  ///
  /// [requestType] is the type of request being displayed.
  /// [onDeleteItem] is the function called when deleting this item.
  /// [onUpdateName] is the function for real-time name updates.
  const RequestTypeItem({
    Key? key,
    required this.requestType,
    required this.onDeleteItem,
    required this.onUpdateName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        tileColor: Theme.of(context).colorScheme.background,
        title: Text(
          requestType.name,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(5),
              ),
              child: IconButton(
                color: Theme.of(context).colorScheme.surface,
                iconSize: 18,
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _editItem(context);
                },
              ),
            ),
            const SizedBox(width: 10), // Add a bit of space between buttons
            Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(5),
              ),
              child: IconButton(
                color: Theme.of(context).colorScheme.surface,
                iconSize: 18,
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _confirmDelete(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Displays a dialog to edit the item's name.
  Future<void> _editItem(BuildContext context) async {
    String newName = requestType.name;
    bool showError = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Edit Item Name'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        newName = value;
                        showError = false;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'New Name',
                    ),
                  ),
                  if (showError)
                    const Text(
                      'Invalid name. Please try again.',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    setState(() {
                      if (newName.isNotEmpty) {
                        // Perform rename operation here
                        requestType.name = newName;
                        onUpdateName(requestType.databasePath, newName);

                        Navigator.of(context).pop();
                      } else {
                        showError = true;
                      }
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Displays a confirmation dialog for item deletion.
  Future<void> _confirmDelete(BuildContext context) async {
    String typedName = '';
    bool showError = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'To confirm, type ',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: '"${requestType.name}"',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                          text: ' in the box below.',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        typedName = value;
                        showError = false;
                      });
                    },
                  ),
                  if (showError)
                    const Text(
                      'You have entered the wrong name.',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    setState(() {
                      if (typedName == requestType.name) {
                        onDeleteItem(requestType.databasePath);
                        Navigator.of(context).pop();
                      } else {
                        showError = true;
                      }
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
