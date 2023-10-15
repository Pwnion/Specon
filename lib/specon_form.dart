import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:specon/models/request_type.dart';
import 'package:specon/models/subject_model.dart';
import 'models/user_model.dart';

import 'page/db.dart';
import 'models/request_model.dart';
import 'package:specon/storage.dart';

class SpeconForm extends StatefulWidget {
  final Function closeNewRequestForm;
  final UserModel currentUser;
  final SubjectModel currentSubject;
  final List<SubjectModel> Function() getSubjectList;
  final void Function(SubjectModel) setCurrentSubject;
  final void Function(RequestModel) openSubmittedRequest;
  final void Function() incrementCounter;

  const SpeconForm(
      {super.key,
      required this.closeNewRequestForm,
      required this.currentUser,
      required this.currentSubject,
      required this.getSubjectList,
      required this.setCurrentSubject,
      required this.openSubmittedRequest,
      required this.incrementCounter});

  @override
  State<SpeconForm> createState() => _SpeconFormState();
}

class _SpeconFormState extends State<SpeconForm> {

  final List<String> _preFilledFieldTitles = [
    'Full Name',
    'Last Name',
    'Email',
  ];

  final Map<String, String> _databaseFields = {
    'Full Name': 'name',
    'Email': 'email',
    'Student ID': 'student_id',
  };

  final List<String> _fieldTitles = [
    'Full Name', // 0
    'Email', // 1
    'Student ID', // 2
    'Subject',
    'Assessment',
    'Request Type',
    'Extend due date to (if applicable)',
    'Additional Information', // 3
    'Reason', // 4
    'Attachments',
    'AAP'
  ];

  late Future<Map<String, dynamic>> basicForm;

  final _dueDateSelectorController = TextEditingController(text: 'Use slider below');
  final _additionalInformationController = TextEditingController();
  final _studentIDController = TextEditingController();
  final _reasonController = TextEditingController();
  final _requestFromController = ScrollController();
  final _mockAssessmentDueDate = DateTime(2023, 10, 1, 23, 59); // TODO: Get initial assessment due date from canvas
  final _mockMaxExtendDays = 10; // TODO: Set by subject coordinator, + 2 days maybe?
  static final List<String> requestTypes = ['Extension', 'Regrade', 'Waiver', 'Others'];
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
  RequestType? selectedAssessment;
  String selectedRequestType = '';
  List<SubjectModel> subjectList = [];
  double _currentSliderValue = 0;
  final List<String> subjectCodeList = [];
  List<RequestType> assessmentList = [];
  List<String> assessmentNameList = [];
  final _assessmentFormKey = GlobalKey<FormState>();
  final _requestTypeFormKey = GlobalKey<FormState>();

  // File related variable
  bool _showClearButton = false;
  bool _aapUpdated = false;
  FilePickerResult? _selectedFiles;
  FilePickerResult? _selectedAap;
  String _displayFileNames = "no file selected";
  String _displayAapName = "original aap (todo)"; // should change to existed one if exist
  UploadTask? _uploadTask;

  void _setDisplayFileName(String name){
    setState(() {
      _displayFileNames = name;
    });
  }
  void _setDisplayAapName(String name){
    setState(() {
      _displayAapName = name;
    });
  }
  void _setAapUpdated(bool value){
    setState(() {
      _aapUpdated = value;
    });
  }
  void _setShowClearButton(bool value){
    setState(() {
      _showClearButton = value;
    });
  }
  void _updateUserAapPath(String aapPath){
    // TODO: u know
  }

  /// clear all file selections and related variables
  void _clearFileVariables(){
    setState(() {
      _selectedFiles = null;
      _displayFileNames = "no file selected";
    });
  }
  /// reset selected aap file and show original aap file name
  void _undoAapSelection(){
    _selectedAap = null;
    setState(() {
      _displayAapName = "original.pdf or none";
    });
  }

  String dateConversionString(int daysExtended) {
    var displayString = '';
    var extendedDate = dateAfterExtension(daysExtended);

    displayString += '${_mockAssessmentDueDate.day}-'
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

    while (daysExtendedExcludingWeekend < daysExtended) {
      if (DateTime(_mockAssessmentDueDate.year, _mockAssessmentDueDate.month,
                  _mockAssessmentDueDate.day + daysExtendedIncludingWeekend + 1)
              .weekday <=
          5) {
        daysExtendedExcludingWeekend++;
      }
      daysExtendedIncludingWeekend++;
    }
    return DateTime(
        _mockAssessmentDueDate.year,
        _mockAssessmentDueDate.month,
        _mockAssessmentDueDate.day + daysExtendedIncludingWeekend,
        _mockAssessmentDueDate.hour,
        _mockAssessmentDueDate.minute);
  }

  Widget buildDropdownField(String field) {
    // Subject field
    if (field == 'Subject') {
      return SizedBox(
        width: 420.0,
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: DropdownButtonFormField(
            value: widget.currentSubject.code,
            items: subjectCodeList
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child:
                    Text(value, style: const TextStyle(color: Colors.white)),
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
              setState(() {
                selectedSubject =  subjectList[subjectCodeList.indexOf(value!)];
                assessmentList = selectedSubject!.assessments;
                assessmentNameList = RequestType.getAssessmentNames(assessmentList);
              });
            }
          ),
        ),
      );
    }

    // Assessment field
    else if (field == 'Assessment') {
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
              items:
                  assessmentNameList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child:
                      Text(value, style: const TextStyle(color: Colors.white)),
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
                selectedAssessment =  assessmentList[assessmentNameList.indexOf(value!)];
              }),
        ),
      );
    }

    // Request Type field
    else {
      return SizedBox(
        width: 420.0,
        child: Form(
          key: _requestTypeFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: DropdownButtonFormField(
              validator: (value) {
                if (value == null) {
                  return 'Please selected a request type';
                }
                return null;
              },
              value: null, // TODO: need to change to match selected subject
              items: requestTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child:
                  Text(value, style: const TextStyle(color: Colors.white)),
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
                selectedRequestType = value!;
              }),
        ),
      );
    }
  }

  Map<String, dynamic> buildForm(UserModel currentUser) {
    final List<Widget> textFormFields = <Widget>[];
    final List<TextEditingController> controllers = <TextEditingController>[];
    Widget attachments = const Text("initialize attachments");
    Widget aap = const Text("initialize aap");

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

      // Subject, Assessment & Request Type field
      else if (field == 'Subject' || field == 'Assessment' || field == 'Request Type') {
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
              style: const TextStyle(
                  color: Colors.white54), // TODO: set color scheme
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
                  if (value == 0.0) {
                    _dueDateSelectorController.text = 'Use slider below';
                  } else {
                    _dueDateSelectorController.text =
                        dateConversionString(value.toInt());
                  }
                });
              },
            ),
          ),
        );
      }

      // select supporting files
      else if (field == 'Attachments'){
        attachments = SizedBox(
          width: 420,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "Select supporting documents (use CTRL to select more files)",
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: ButtonStyle(
                        shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                                side: BorderSide(color: Theme.of(context).colorScheme.secondary)
                            )
                        )
                    ),
                    onPressed: () async {
                      _selectedFiles = await selectFile();
                      _setDisplayFileName(_selectedFiles!.names.join("\n"));
                      _setShowClearButton(true);
                    },
                    child: Text('Select Files', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary)
                    ),
                  ),
                  // display selected file names
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(17.0),
                        child: Text(
                          _displayFileNames,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                    ),
                  ),

                  // clear selection button
                  Visibility(
                    visible: _showClearButton,
                    child: TextButton(
                      onPressed: (){
                        _clearFileVariables();
                        _setShowClearButton(false);
                      }, //downloadAttachment,
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                      ),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }

      // select aap file
      else if (field == 'AAP'){
        aap = SizedBox(
          width: 420,
          // used to have expanded widget
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "If you have an AAP or want to update the existed one\nplease provide it down below",
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: ButtonStyle(
                        shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                                side: BorderSide(color: Theme.of(context).colorScheme.secondary)
                            )
                        )
                    ),
                    onPressed: () async {
                      // AAP document should only be one
                      _selectedAap = await selectSingleFile();
                      _setDisplayAapName(_selectedAap!.names.join());
                      _setAapUpdated(true);
                    },
                    child: Text('Select AAP', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary)
                    ),
                  ),
                  // display selected file names
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(17.0),
                        child: Text(
                          _displayAapName,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _aapUpdated,
                    child: TextButton(
                      onPressed: (){
                        _undoAapSelection();
                        _setShowClearButton(false);
                      }, //downloadAttachment,
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                      ),
                      child: Text(
                        'Undo',
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }

      // To be filled fields
      else {
        TextEditingController controller;
        if (field == 'Additional Information') {
          controller = _additionalInformationController;
        }else if (field == 'Student ID'){
          controller = _studentIDController;
        } else {
          controller = _reasonController;
        }
        controllers.add(controller);

        textFormFields.add(
          SizedBox(
            width: 420.0,
            child: TextFormField(
              enabled: true,
              maxLines: null,
              controller: controller,
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
                  fontSize: 18
                ),
                floatingLabelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 22
                ),
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
    return {'Form': textFormFields, 'Controllers': controllers, 'Attachments': attachments, 'AAP': aap};
  }

  @override
  void initState() {
    subjectList = widget.getSubjectList();

    for (final subject in subjectList) {
      subjectCodeList.add(subject.code);
    }

    selectedSubject = widget.currentSubject;
    assessmentList = widget.currentSubject.assessments;
    assessmentNameList = RequestType.getAssessmentNames(assessmentList);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> form = buildForm(widget.currentUser);
    final List<TextEditingController> controllers = form['Controllers'];
    final List<Widget> textFields = form['Form'];
    final Widget attachments = form['Attachments'];
    final Widget aap = form['AAP'];

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

            // attachment part
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                attachments,
              ],
            ),
            const SizedBox(height: 20),
            // AAP part
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                aap,
              ],
            ),

            const SizedBox(height: 20),
            // Submit button
            ElevatedButton(
              onPressed: () async {
                // Check validity of dropdowns
                if (!_assessmentFormKey.currentState!.validate() ||
                    !_requestTypeFormKey.currentState!.validate()) {
                  return;
                }

                final RequestModel request = RequestModel(
                  requestedBy: controllers[0].text,
                  requestedByStudentID: widget.currentUser.id,
                  assessedBy: '',
                  assessment: selectedAssessment!,
                  reason: _reasonController.text,
                  additionalInfo: _additionalInformationController.text,
                  state: 'Open',
                  databasePath: ''
                );
                DocumentReference docRef = await dataBase.submitRequest(
                    widget.currentUser,
                    selectedSubject == null
                        ? widget.currentSubject
                        : selectedSubject!,
                    request); //
                widget.closeNewRequestForm();
                widget.setCurrentSubject(selectedSubject == null
                    ? widget.currentSubject
                    : selectedSubject!);
                // TODO: selected the submitted request

                // upload selected files
                if(_selectedFiles != null){
                  _uploadTask = uploadFile(docRef.id, _selectedFiles!);
                }
                if(_aapUpdated){
                  // right now hard coded to user jerrya 12345678
                  uploadFile("aRTMyP7HK7HV7RgOkMw6", _selectedAap!);

                  // TODO: update aapPath for user after uploading aap
                  _updateUserAapPath("aRTMyP7HK7HV7RgOkMw6");
                }
                // clear all variables\
                _clearFileVariables();

                widget.openSubmittedRequest(
                  RequestModel(
                    requestedBy: controllers[0].text,
                    requestedByStudentID: widget.currentUser.id,
                    assessedBy: '',
                    assessment: selectedAssessment!,
                    reason: _reasonController.text,
                    additionalInfo: _additionalInformationController.text,
                    state: 'Open',
                    databasePath: docRef.path
                  )
                );
                widget.incrementCounter();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  List<TextField> displayRequest(RequestModel request) {
    List<TextField> form = [];

    Map<String, dynamic> requestMap = request.toJson();
    for (String key in requestMap.keys) {
      TextField info = TextField(
        readOnly: true,
        controller: TextEditingController(text: requestMap[key]),
        style: const TextStyle(color: Colors.white54), // TODO: Color theme
        cursorColor: Theme.of(context).colorScheme.onSecondary,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onSecondary,
              width: 0.5,
            ),
          ),
          labelText: key,
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
      );
      form.add(info);
    }

    return form;
  }
}
