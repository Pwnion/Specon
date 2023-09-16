import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'models/userModel.dart';

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
    'first_name',
    'last_name',
    'email',
    'student_id',
  ];

  static const List<String> _toFillFields = [
    'Subject',
    'Additional Information',
    'Reason'
  ];

  String requestType = '';
  late final Future<Map<String, dynamic>> basicForm;

  Future<Map<String, dynamic>> buildForm(
      List<String> preFilled, List<String> toFill) async {
    final List<Widget> textFormFields = <Widget>[];
    final List<TextEditingController> controllers = <TextEditingController>[];
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser!;
    print("BITCH FACE");

    final dataBase = DataBase();

    print("CUNT");

    final UserModel currentUser =
        await dataBase.getUserFromEmail("email", user.email!);
    print("POOOO");
    final Map<String, dynamic> jsonUser = currentUser.toJson();

    for (final field in preFilled) {
      final TextEditingController newController =
          TextEditingController(text: jsonUser[field]);
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
  void initState() {
    super.initState();

    basicForm = buildForm(_preFilledFieldTitles, _toFillFields);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: basicForm,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print(snapshot.hasData);
            final List<TextEditingController> controllers =
                snapshot.data!['Controllers'];
            final List<Widget> textFields = snapshot.data!['Form'];

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
                        icon: const Icon(Icons.close,
                            size: 40.0, color: Colors.white),
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
                        color: Theme.of(context).colorScheme.background,
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
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      Theme.of(context).colorScheme.onSecondary,
                                  decorationThickness: 2)),
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
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
