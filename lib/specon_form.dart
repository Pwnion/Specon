import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:specon/models/subject_model.dart';
import 'models/userModel.dart';

import 'page/db.dart';
import 'models/request_model.dart';

class SpeconForm extends StatefulWidget {
  final Function closeNewRequestForm;
  final String currentSubjectCode;
  final UserModel currentUser;
  final SubjectModel currentSubject;

  const SpeconForm(
    {
      super.key,
      required this.closeNewRequestForm,
      required this.currentSubjectCode,
      required this.currentUser,
      required this.currentSubject
    }
  );

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

  static const List<String> _fieldTitles = [
    'first_name',
    'last_name',
    'email',
    'student_id',
    'Subject',
    'Extend due date to (if applicable)',
    'Additional Information',
    'Reason'
  ];

  String requestType = '';
  late Future<Map<String, dynamic>> basicForm;

  final _dueDateSelectorController = TextEditingController(text: 'Use slider below');
  final _requestFromController = ScrollController();
  final _mockAssessmentDueDate = DateTime(2023, 10, 1, 23, 59); // TODO: Get initial assessment due date from canvas
  final _mockMaxExtendDays = 10; // TODO: Set by subject coordinator, + 2 days maybe?
  final Map<int, String> dayName = {
    1: 'MON',
    2: 'TUE',
    3: 'WED',
    4: 'THU',
    5: 'FRI',
    6: 'SAT',
    7: 'SUN'
  };
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final dataBase = DataBase();
  final Future<UserModel> currentUser = dataBase.getUserFromEmail(auth.currentUser!.email!);
  double _currentSliderValue = 0;

  String dateConversionString(int daysExtended) {

    var displayString = '';
    var extendedDate = dateAfterExtension(daysExtended);

    displayString +=
    '${_mockAssessmentDueDate.day}-'
        '${_mockAssessmentDueDate.month}-'
        '${_mockAssessmentDueDate.year} '
        '${_mockAssessmentDueDate.hour}'
        ':'
        '${_mockAssessmentDueDate.minute}'
        ' [${dayName[_mockAssessmentDueDate.weekday]}]'
        '  -->  '
        '${extendedDate.day}-'
        '${extendedDate.month}-'
        '${extendedDate.year} '
        '${extendedDate.hour}'
        ':'
        '${extendedDate.minute}'
        ' [${dayName[extendedDate.weekday]}]';

    return displayString;
  }

  DateTime dateAfterExtension(int daysExtended) {

    int daysExtendedExcludingWeekend = 0;
    int daysExtendedIncludingWeekend = 0;

    while(daysExtendedExcludingWeekend < daysExtended) {
      if(DateTime(_mockAssessmentDueDate.year,_mockAssessmentDueDate.month, _mockAssessmentDueDate.day + daysExtendedIncludingWeekend + 1).weekday <= 5) {
        daysExtendedExcludingWeekend++;
      }
      daysExtendedIncludingWeekend++;
    }
    return DateTime(
        _mockAssessmentDueDate.year,
        _mockAssessmentDueDate.month,
        _mockAssessmentDueDate.day + daysExtendedIncludingWeekend,
        _mockAssessmentDueDate.hour,
        _mockAssessmentDueDate.minute
    );
  }

  Map<String, dynamic> buildForm(UserModel currentUser) {
    final List<Widget> textFormFields = <Widget>[];
    final List<TextEditingController> controllers = <TextEditingController>[];

    final Map<String, dynamic> jsonUser = currentUser.toJson();

    for (final field in _fieldTitles) {

      // Prefilled fields
      if (_preFilledFieldTitles.contains(field)) {
        final TextEditingController newController =
        TextEditingController(text: jsonUser[field]);
        controllers.add(newController);
        textFormFields.add(
          SizedBox(
            width: 420.0,
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

      // Slider
      else if (field == 'Extend due date to (if applicable)') {

        // Display dates
        textFormFields.add(
          SizedBox(
            width: 420.0,
            child: TextFormField(
              readOnly: true,
              controller: _dueDateSelectorController,
              style: const TextStyle(color: Colors.white54), // TODO: set color scheme
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
        //Slider
        textFormFields.add(
          SizedBox(
            height: 60.0,
            width: 420.0,
            child: Slider(
              value: _currentSliderValue,
              max: _mockMaxExtendDays.toDouble(),
              divisions: _mockMaxExtendDays,
              label: '${_currentSliderValue.round().toString()} days',
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                  if(value == 0.0) {
                    _dueDateSelectorController.text = 'Use slider below';
                  }
                  else {
                    _dueDateSelectorController.text = dateConversionString(value.toInt());
                  }
                });
              },
            ),
          ),
        );
      }

      // To be filled fields
      else {
        final TextEditingController newController = TextEditingController();
        controllers.add(newController);

        textFormFields.add(
          SizedBox(
            width: 420.0,
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
    return Scrollbar(
      thumbVisibility: true,
      controller: _requestFromController,
      child: SingleChildScrollView(
        controller: _requestFromController,
        child: FutureBuilder(
          future: currentUser,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final Map<String, dynamic> form = buildForm(snapshot.data!);
              final List<TextEditingController> controllers =
                  form['Controllers'];
              final List<Widget> textFields = form['Form'];

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
                        state: "open",
                      );
                      dataBase.submitRequest(widget.currentUser, widget.currentSubject, request);
                      widget.closeNewRequestForm();
                    },
                    child: const Text('Submit'),
                  ),
                ],
              );
            } else {
              return const CircularProgressIndicator();
            }
          }
        ),
      ),
    );
  }
}
