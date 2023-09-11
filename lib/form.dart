import 'package:flutter/material.dart';
import 'package:specon/models/changeTuteModel.dart';
import 'package:specon/models/extensionModel.dart';
import 'package:specon/models/otherReasonModel.dart';
import 'package:specon/models/participationWaiverModel.dart';
import 'models/requestModel.dart';
import 'page/db.dart';

class SpeconForm extends StatefulWidget {
  final Function closeNewRequestForm;

  const SpeconForm({super.key, required this.closeNewRequestForm});

  @override
  State<SpeconForm> createState() => _SpeconFormState();
}

class _SpeconFormState extends State<SpeconForm> {
  final primary = const Color(0xFF385F71);
  final onPrimary = const Color(0xFFDF6C00);
  final secondary = const Color(0xFF333333);
  final onSecondary = const Color(0xFFD4D4D4);
  String requestType = '';

  static const List<String> fieldTitles = [
    "Given Name",
    "Last Name",
    "Email",
    "Student ID",
    "Subject",
    "Additional Information",
    "Reason"
  ];

  Map<String, dynamic> buildForm(List<String> fields) {
    List<Widget> textFormFields = [];
    List<TextEditingController> controllers = [];

    for (var field in fields) {
      TextEditingController newController = TextEditingController();
      controllers.add(newController);
      textFormFields.add(
        SizedBox(
          width: 300.0,
          child: TextFormField(
            controller: newController,
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

    return {"Form": textFormFields, "Controllers": controllers};
  }

  List<DropdownMenuItem<String>> buildRequestType(Map requestTypes) {
    List<DropdownMenuItem<String>> requestTypesList = [];

    for (var requestType in requestTypes.keys) {
      requestTypesList.add(DropdownMenuItem(
        value: requestType,
        child: Text(requestType, style: const TextStyle(color: Colors.white)),
      ));
    }

    return requestTypesList;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> basicForm = buildForm(fieldTitles);
    List<TextEditingController> controllers = basicForm["Controllers"];
    List<Widget> textFields = basicForm["Form"];

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
                color: secondary,
                child: Column(
                  children: textFields,
                ),
              ),
            ),

            //const SizedBox(width: 30.0),

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
                  //       controllers = basicForm["Controllers"];
                  //       setState(() {
                  //         requestType = value!;
                  //       });
                  //     }),

                  const SizedBox(height: 15),

                  Text(requestType,
                      style: TextStyle(
                          fontSize: 20.0,
                          color: onSecondary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: onSecondary,
                          decorationThickness: 2)),

                  if (requestType.isNotEmpty) const SizedBox(height: 23),

                  if (requestType.isNotEmpty)
                    Container(
                      color: secondary,
                      child: Column(children: [] //basicForm["Form"],
                          ),
                    ),
                ]),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: () async {
            final dataBase = DataBase();

            RequestModel request = RequestModel(
              studentId: controllers[0].text,
              firstName: controllers[1].text,
              lastName: controllers[2].text,
              emailAddress: controllers[3].text,
              subject: controllers[4].text,
              additionalInfo: controllers[5].text,
              reason: controllers[6].text,
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
