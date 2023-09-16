import 'package:flutter/material.dart';

import 'page/db.dart';
import 'models/request_model.dart';

class SpeconForm extends StatefulWidget {
  final Function closeNewRequestForm;

  const SpeconForm(
    {
      super.key,
      required this.closeNewRequestForm
    }
  );

  @override
  State<SpeconForm> createState() => _SpeconFormState();
}

class _SpeconFormState extends State<SpeconForm> {
  static const List<String> _fieldTitles = [
    'Given Name',
    'Last Name',
    'Email',
    'Student ID',
    'Subject',
    'Additional Information',
    'Reason'
  ];

  String requestType = '';
  
  Map<String, dynamic> buildForm(List<String> fields) {
    final List<Widget> textFormFields = <Widget>[];
    final List<TextEditingController> controllers = <TextEditingController>[];
    for (final field in fields) {
      final TextEditingController newController = TextEditingController();
      controllers.add(newController);
      textFormFields.add(
        SizedBox(
          width: 300.0,
          child: TextFormField(
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
              labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 18),
              floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 22),
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
    final Map<String, dynamic> basicForm = buildForm(_fieldTitles);
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
                  // Request type button
                  // DropdownButton(
                  //     hint: const Text('Request Type'),
                  //     // enableFeedback: true,
                  //     //items: buildRequestType(typesOfRequest),
                  //     onChanged: (value) {
                  //       basicForm =
                  //           buildForm(basicFieldTitles + typesOfRequest[value]);
                  //       controllers = basicForm['Controllers'];
                  //       setState(() {
                  //         requestType = value!;
                  //       });
                  //     }),
                  const SizedBox(height: 15),
                  Text(requestType,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Theme.of(context).colorScheme.onSecondary,
                      decorationThickness: 2
                    )
                  ),
                  if (requestType.isNotEmpty) const SizedBox(height: 23),
                  if (requestType.isNotEmpty)
                    Container(
                      color: Theme.of(context).colorScheme.secondary,
                      child: const Column(
                        children: [] //basicForm['Form'],
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
          onPressed: () async {
            final dataBase = DataBase();
            final RequestModel request = RequestModel(
              studentId: controllers[0].text,
              firstName: controllers[1].text,
              lastName: controllers[2].text,
              email: controllers[3].text,
              subject: controllers[4].text,
              reason: controllers[6].text,
              additionalInfo: controllers[5].text,
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