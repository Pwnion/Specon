import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:specon/models/subject_model.dart';
import 'models/user_model.dart';

import 'page/db.dart';
import 'models/request_model.dart';

class SpeconForm extends StatefulWidget {
  final Function closeNewRequestForm;
  final UserModel currentUser;
  final SubjectModel currentSubject;
  final List<SubjectModel> Function() getSubjectList;
  final void Function(SubjectModel) setCurrentSubject;

  const SpeconForm(
    {
      super.key,
      required this.closeNewRequestForm,
      required this.currentUser,
      required this.currentSubject,
      required this.getSubjectList,
      required this.setCurrentSubject
    }
  );

  @override
  State<SpeconForm> createState() => _SpeconFormState();
}

class _SpeconFormState extends State<SpeconForm> {

  final List<String> _preFilledFieldTitles = [
  'First Name',
  'Last Name',
  'Email',
  'Student ID',
  ];

  final Map<String, String> _databaseFields = {
    'First Name': 'first_name',
    'Last Name': 'last_name',
    'Email': 'email',
    'Student ID': 'student_id',
  };

  final List<String> _fieldTitles = [
    'First Name', // 0
    'Last Name', // 1
    'Email', // 2
    'Student ID', // 3
    'Subject',
    'Assessment',
    'Extend due date to (if applicable)',
    'Additional Information', // 4
    'Reason' // 5
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
  SubjectModel? selectedSubject;
  String selectedAssessment = '';
  List<SubjectModel> subjectList = [];
  double _currentSliderValue = 0;
  final List<String> subjectNamesList = [];
  final List<String> assessmentList = ['Project 1', 'Project 2', 'Project 3', 'Mid Semester Test', 'Final Exam', 'Others']; // TODO: Need to get from database
  final _subjectFormKey = GlobalKey<FormState>();
  final _assessmentFormKey = GlobalKey<FormState>();


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

  Widget buildDropdownField(String field) {

    // Subject field
    if(field == 'Subject') {
      return SizedBox(
        width: 420.0,
        child: Form(
          key: _subjectFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: DropdownButtonFormField(
            validator: (value) {
              if (value == null) {
                return 'Please selected a subject';
              }
              return null;
            },
            value: widget.currentSubject.code.isNotEmpty ? widget.currentSubject.code : null,
            items: subjectNamesList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
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
                  fontSize: 18),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFD78521),
                  width: 1,
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {
                selectedSubject = subjectList[subjectNamesList.indexOf(value!)];
              });
            }
          ),
        ),
      );
    }

    // Assessment field
    else {
      return SizedBox(
        width: 420.0,
        child: Form(
          key: _assessmentFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: DropdownButtonFormField(
            validator: (value) {
              if (value == null) {
                return 'Please selected an assessment';
              }
              return null;
            },
            value: null, // TODO: need to change to match selected subject
            items: assessmentList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
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
                fontSize: 18
              ),
              floatingLabelStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: 18
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFD78521),
                  width: 1,
                ),
              ),
            ),
            onChanged: (value) {
              selectedAssessment = value!;
            }
          ),
        ),
      );
    }
  }

  Map<String, dynamic> buildForm(UserModel currentUser) {
    final List<Widget> textFormFields = <Widget>[];
    final List<TextEditingController> controllers = <TextEditingController>[];

    final Map<String, dynamic> jsonUser = currentUser.toJson();

    for (final field in _fieldTitles) {

      // Prefilled fields
      if (_preFilledFieldTitles.contains(field)) {
        final TextEditingController newController =
        TextEditingController(text: jsonUser[_databaseFields[field]]);
        controllers.add(newController);
        textFormFields.add(
          SizedBox(
            width: 420.0,
            child: TextField(
              readOnly: true,
              // enabled: false,
              controller: newController,
              style: const TextStyle(color: Colors.white54), // TODO: Color theme
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

      // Subject & Assessment field
      else if (field == 'Subject' || field == 'Assessment') {
        textFormFields.add(buildDropdownField(field));
        textFormFields.add(const SizedBox(height: 15.0));
      }

      // Extension date field
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
              maxLines: null,
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

  @override
  void initState() {
    subjectList = widget.getSubjectList();

    for (final subject in subjectList){
      subjectNamesList.add(subject.code);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final Map<String, dynamic> form = buildForm(widget.currentUser);
    final List<TextEditingController> controllers = form['Controllers'];
    final List<Widget> textFields = form['Form'];

    return Scrollbar(
      thumbVisibility: true,
      controller: _requestFromController,
      child: SingleChildScrollView(
        controller: _requestFromController,
        child: Column(
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
            // Submit button
            ElevatedButton(
              onPressed: () async {

                // Check validity of dropdowns
                if (!_subjectFormKey.currentState!.validate() ||
                    !_assessmentFormKey.currentState!.validate()) {
                  return;
                }

                final RequestModel request = RequestModel(
                  requestedBy: controllers[0].text,
                  requestedByStudentID: widget.currentUser.studentID,
                  assessedBy: '',
                  assessment: selectedAssessment,
                  reason: controllers[5].text,
                  additionalInfo: controllers[4].text,
                  state: 'Open',
                );
                await dataBase.submitRequest(
                  widget.currentUser,
                  selectedSubject == null ? widget.currentSubject : selectedSubject!,
                  request
                ); //
                widget.closeNewRequestForm();
                widget.setCurrentSubject(
                  selectedSubject == null ? widget.currentSubject : selectedSubject!
                );
                // TODO: selected the submitted request
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
