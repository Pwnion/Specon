/// The form part of the [Dashboard] page.
///
/// A student will fill out this form, and a tutor or subject coordinator
/// will review it.

import 'package:flutter/material.dart';

import '../dashboard_page.dart';

class ConsiderationForm extends StatefulWidget {

  final Function closeNewRequestForm;

  const ConsiderationForm({Key? key, required this.closeNewRequestForm}) : super(key: key);

  @override
  State<ConsiderationForm> createState() => _ConsiderationFormState();
}

class _ConsiderationFormState extends State<ConsiderationForm> {

  final primary = const Color(0xFF385F71);
  final onPrimary = const Color(0xFFDF6C00);
  final secondary = const Color(0xFF333333);
  final onSecondary = const Color(0xFFD4D4D4);
  String requestType = '';

  // TODO: Customisable or standard?
  static const List<String> basicFieldTitles = [
    "Given Name",
    "Last Name",
    "Email",
    "Student ID",
    "Subject"
  ];

  // TODO: Should be customisable by the subject coordinator
  static const Map typesOfRequest = {
    "Participation Waiver": [
      "Class",
      "Reason"
    ],
    "Due date extension": [
      "How long",
      "Reason"
    ],
    "Change tutorial": [
      "From Class",
      "To Class",
      "Reason"
    ],
    "Others": [
      "What",
      "Why",
    ],
  };

  List<Widget> buildColumn(List<String> fields) {
    List<Widget> textFormFields = [];

    for (var field in fields) {
      textFormFields.add(
        SizedBox(
          width: 300.0,
          child: TextFormField(

            style: TextStyle(color: onSecondary),

            cursorColor: onSecondary,

            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: onSecondary,
                  width: 0.5,
                ),
              ),

              labelText: field,
              labelStyle: TextStyle(color: onSecondary, fontSize: 18),

              floatingLabelStyle: TextStyle(color: onSecondary, fontSize: 22),
              floatingLabelBehavior: FloatingLabelBehavior.always,

              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFD78521),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      );
      textFormFields.add(const SizedBox(height: 15));
    }

    return textFormFields;
  }

  List<DropdownMenuItem<String>> buildRequestType(Map requestTypes) {

    List<DropdownMenuItem<String>> requestTypesList = [];

    for (var requestType in requestTypes.keys) {

      requestTypesList.add(
          DropdownMenuItem(
            value: requestType,
            child: Text(requestType, style: const TextStyle(color: Colors.white)),
          )
      );
    }

    return requestTypesList;

  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        Stack(
          children: [

            // X button to close form
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    widget.closeNewRequestForm();
                  });
                },
                icon: const Icon(Icons.close, size: 40.0, color: Colors.white),
              ),
            ),

            // Form title
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.only(top: 10.0),
                child: const Text('Request Form', style: TextStyle(fontSize: 30.0, color: Colors.white),),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20.0),

        // Information part
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const SizedBox(width: 40.0),

            // Basic information column
            Expanded(
              flex: 1,
              child: Container(
                color: secondary,
                child: Column(
                  children: [
                    ...buildColumn(basicFieldTitles),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 30.0),

            // Detailed information column
            Expanded(
              flex: 1,
              child: Center(
                child: Column(
                    children: [

                      // Request type button
                      DropdownButton(
                          hint: const Text('Request Type'),
                          // enableFeedback: true,
                          items: [
                            ...buildRequestType(typesOfRequest),
                          ],
                          onChanged: (value) {
                            setState(() {
                              requestType = value!;
                            });
                          }
                      ),

                      const SizedBox(height: 15),

                      Text(requestType, style: TextStyle(fontSize: 20.0, color: onSecondary, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: onSecondary, decorationThickness: 2)),

                      if (requestType.isNotEmpty)
                        const SizedBox(height: 23),

                      if (requestType.isNotEmpty)
                        Container(
                          color: secondary,
                          child:  Column(
                            children: [
                              ...buildColumn(typesOfRequest[requestType]),
                            ],
                          ),
                        ),
                    ]
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: ()  async {
            //TODO: send request to database
            widget.closeNewRequestForm();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}