import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'page/db.dart';
import 'models/request_model.dart';

class SpeconForm extends StatefulWidget {
  final Function closeNewRequestForm;

  const SpeconForm({super.key, required this.closeNewRequestForm});

  @override
  State<SpeconForm> createState() => _SpeconFormState();
}

class _SpeconFormState extends State<SpeconForm> {
  static const List<String> _preFilledFieldTitles = [
    'Given Name',
    'Last Name',
    'Email',
    'Student ID',
  ];

  static const List<String> _toFillFields = [
    'Subject',
    'Additional Information',
    'Reason'
  ];

  String requestType = '';

  Map<String, dynamic> buildForm(List<String> preFilled, List<String> toFill) {
    final List<Widget> textFormFields = <Widget>[];
    final List<TextEditingController> controllers = <TextEditingController>[];
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser!;

    for (final field in toFill) {
      final TextEditingController newController =
          TextEditingController(text: user.email);
      controllers.add(newController);
      textFormFields.add(
        SizedBox(
          width: 300.0,
          child: TextField(
            enabled: false,
            controller: newController,
            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
            cursorColor: Theme.of(context).colorScheme.onSecondary,
            decoration: InputDecoration(
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onSecondary,
                  width: 0.5,
                ),
              ),
              labelText: field,
              labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 18),
              floatingLabelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 18),
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

    for (final field in toFill) {
      final TextEditingController newController = TextEditingController();
      controllers.add(newController);

      textFormFields.add(
        SizedBox(
          width: 300.0,
          child: TextFormField(
            enabled: true,
            controller: newController,
            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
            cursorColor: Theme.of(context).colorScheme.onSecondary,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onSecondary,
                  width: 0.5,
                ),
              ),
              labelText: field,
              labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 18),
              floatingLabelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 22),
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
    return {'Form': textFormFields, 'Controllers': controllers};
  }

  List<DropdownMenuItem<String>> buildRequestType(Map requestTypes) {
    return requestTypes.keys.map((requestType) {
      return DropdownMenuItem<String>(
        value: requestType,
        child: Text(requestType, style: const TextStyle(color: Colors.white)),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> basicForm =
        buildForm(_preFilledFieldTitles, _toFillFields);
    final List<TextEditingController> controllers = basicForm['Controllers'];
    final List<Widget> textFields = basicForm['Form'];

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
                child: const Text(
                  'Request Form',
                  style: TextStyle(fontSize: 30.0, color: Colors.white),
                ),
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
                color: Theme.of(context).colorScheme.secondary,
                child: Column(
                  children: textFields,
                ),
              ),
            ),
            // Detailed information column
            Expanded(
              flex: 1,
              child: Center(
                child: Column(children: [
                  const SizedBox(height: 15),
                  Text(requestType,
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              Theme.of(context).colorScheme.onSecondary,
                          decorationThickness: 2)),
                  // if (requestType.isNotEmpty) const SizedBox(height: 23),
                  // if (requestType.isNotEmpty)
                  //   Container(
                  //     color: Theme.of(context).colorScheme.secondary,
                  //     child: const Column(
                  //       children: []
                  //     ),
                  //   ),
                ]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            final dataBase = DataBase();
            final RequestModel request = RequestModel(
              requested_user_id: controllers[0].text,
              assessed_user_id: controllers[0].text,
              subject: controllers[4].text,
              reason: controllers[6].text,
              additional_info: controllers[5].text,
              status: "open",
            );
            dataBase.createRequest(request);
            widget.closeNewRequestForm();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
