import 'package:flutter/material.dart';

import '../model/request_type.dart';
import '../constants/colors.dart';

class RequestTypeItem extends StatelessWidget {
  final RequestType requestType;
  final onDeleteItem;

  const RequestTypeItem({
    Key? key,
    required this.requestType,
    required this.onDeleteItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        tileColor: tdBlack,
        title: Text(
          requestType.name!,
          style: TextStyle(
            fontSize: 16,
            color: textColor,
          ),
        ),
        subtitle: Text(
          requestType.type!, // Display the request type as a subtitle
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.all(0),
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: tdRed,
            borderRadius: BorderRadius.circular(5),
          ),
          child: IconButton(
            color: Colors.white,
            iconSize: 18,
            icon: Icon(Icons.delete),
            onPressed: () {
              onDeleteItem(requestType.id);
            },
          ),
        ),
      ),
    );
  }
}
