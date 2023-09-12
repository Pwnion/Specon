import 'package:flutter/material.dart';

import '../model/request_type.dart';

class RequestTypeItem extends StatelessWidget {
  final RequestType requestType;
  final Function onDeleteItem;

  const RequestTypeItem(
    {
      Key? key,
      required this.requestType,
      required this.onDeleteItem,
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 5
        ),
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
              onDeleteItem(requestType.id);
            },
          ),
        ),
      ),
    );
  }
}
