import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  final String text;
  const Loading(
    {
      Key? key,
      required this.text
    }
  ) : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(
              right: 20.0
            ),
            child: CircularProgressIndicator()
          ),
          Text(
            widget.text
          )
        ],
      )
    );
  }
}
