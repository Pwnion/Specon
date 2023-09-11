import 'package:flutter/material.dart';

import '../model/request_type.dart';

class RequestTypeItem extends StatelessWidget {
  final RequestType requestType;
  final Function onDeleteItem;

  const RequestTypeItem({
    Key? key,
    required this.requestType,
    required this.onDeleteItem,
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
        subtitle: Text(
          requestType.type, // Display the request type as a subtitle
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        trailing: Container(
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
      ),
    );
  }

  Future<void> _editItem(BuildContext context) async {
    String newName = requestType.name!;
    bool showError = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Edit Item Name'),
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
                    decoration: InputDecoration(
                      labelText: 'New Name',
                    ),
                  ),
                  if (showError)
                    Text(
                      'Invalid name. Please try again.',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    setState(() {
                      if (newName.isNotEmpty) {
                        // Perform rename operation here
                        requestType.name = newName;
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
              title: Text('Confirm Delete'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'To confirm, type ',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: '"${requestType.name}"',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
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
                    Text(
                      'You have entered the wrong name.',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Delete'),
                  onPressed: () {
                    setState(() {
                      if (typedName == requestType.name) {
                        onDeleteItem(requestType.id);
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
