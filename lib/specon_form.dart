/// The request form part of the [Dashboard] page.
///
/// This will display a request form with prefilled fields and to be filled
/// fields that a student needs to fill in, to submit a request
/// Author: Jeremy Annal, Zhi Xiang Chan (Lucas)

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:specon/models/request_type.dart';
import 'package:specon/models/subject_model.dart';
import 'models/user_model.dart';

import 'db.dart';
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

  static final List<String> _preFilledFieldTitles = [
    'Full Name',
    'Email',
    'Student ID'
  ];

  static final Map<String, String> _databaseFields = {
    'Full Name': 'name',
    'Email': 'email',
    'Student ID': 'student_id',
  };

  static final List<String> _fieldTitles = [
    'Full Name',
    'Email',
    'Student ID',
    'Subject',
    'Assessment',
    'Request Type',
    'Extend due date to (For extension request type only)',
    'Additional Information',
    'Reason',
    'Attachments',
    'AAP'
  ];

  late Future<Map<String, dynamic>> basicForm;

  final _dueDateSelectorController = TextEditingController(text: 'Use slider below');
  final _additionalInformationController = TextEditingController();
  final _reasonController = TextEditingController();
  final _requestFromController = ScrollController();
  final _mockAssessmentDueDate = DateTime(2023, 10, 1, 23, 59); // TODO: Get initial assessment due date from canvas
  final _mockMaxExtendDays = 10; // TODO: Set by subject coordinator, + 2 days maybe?
  final businessDaysOnly = true; // TODO: Decided by subject coordinator
  static final List<String> requestTypes = ['Extension', 'Regrade', 'Waiver', 'Others'];
  static final Map<int, String> dayName = {
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
  SubjectModel selectedSubject = SubjectModel.emptySubject;
  RequestType selectedAssessment = RequestType.emptyAssessment;
  String selectedRequestType = '';
  List<SubjectModel> subjectList = [];
  double _currentSliderValue = 0;
  int daysExtending = 0;
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
  //String _originalAapName = "";
  String _displayAapName = "";
  UploadTask? _uploadTask;
  late final _originalAapName;

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
  // void _setAapUpdated(bool value){
  //   setState(() {
  //     _aapUpdated = value;
  //   });
  // }
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
      _displayAapName = "";
    });
  }

  /// Function that returns a string to display the before and after due dates
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

  /// Function that calculates the date after a given number of extension days
  DateTime dateAfterExtension(int daysExtended) {
    int daysExcludingWeekend = 0;
    int daysIncludingWeekend = 0;
    final year = _mockAssessmentDueDate.year;
    final month = _mockAssessmentDueDate.month;
    final day = _mockAssessmentDueDate.day;

    while (daysExcludingWeekend < daysExtended) {

      if (DateTime(year, month, day + daysIncludingWeekend + 1).weekday <= 5) {
        daysExcludingWeekend++;
      }
      daysIncludingWeekend++;
    }

    if(!businessDaysOnly) {
      daysIncludingWeekend = daysExtended;
    }

    setState(() {
      daysExtending = daysIncludingWeekend;
    });

    return DateTime(
      _mockAssessmentDueDate.year,
      _mockAssessmentDueDate.month,
      _mockAssessmentDueDate.day + daysIncludingWeekend,
      _mockAssessmentDueDate.hour,
      _mockAssessmentDueDate.minute
    );
  }

  /// Function that builds dropdowns for subject, assessment and request type
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
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.white)
                ),
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
                assessmentList = selectedSubject.assessments;
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
                setState(() {
                  selectedAssessment =  assessmentList[assessmentNameList.indexOf(value!)];
                });
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
            value: null,
            items: requestTypes.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.white)
                ),
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
                selectedRequestType = value!;
              });
            }
          ),
        ),
      );
    }
  }

  /// Function that is responsible for building the entire request form
  Map<String, dynamic> buildForm(UserModel currentUser) {
    final List<Widget> textFormFields = <Widget>[];
    Widget attachments = const Text("initialize attachments");
    Widget aap = const Text("initialize aap");

    final Map<String, dynamic> jsonUser = currentUser.toJson();

    for (final field in _fieldTitles) {
      // Prefilled fields
      if (_preFilledFieldTitles.contains(field)) {

        TextEditingController controller;

        if(field == 'Student ID') {
          controller = TextEditingController(text:currentUser.studentID);
        }
        else {
          controller = TextEditingController(text: jsonUser[_databaseFields[field]]);
        }

        textFormFields.add(
          SizedBox(
            width: 420.0,
            child: TextField(
              readOnly: true,
              controller: controller,
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
      else if (field == 'Extend due date to (For extension request type only)') {
        // Display dates
        textFormFields.add(
          SizedBox(
            width: 420.0,
            child: TextFormField(
              readOnly: true,
              controller: _dueDateSelectorController,
              style: const TextStyle(
                color: Colors.white54
              ), // TODO: set color scheme
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSecondary,
                    width: 0.5,
                  ),
                ),
                labelText: field,
                floatingLabelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 20
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
              onChanged: selectedAssessment.name.isNotEmpty && selectedRequestType == 'Extension' ? (double value) {
                setState(() {
                  _currentSliderValue = value;
                  if (value == 0.0) {
                    _dueDateSelectorController.text = 'Use slider below';
                  } else {
                    _dueDateSelectorController.text =
                        dateConversionString(value.toInt());
                  }
                });
              } : null,
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary
                    )
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
                          side: BorderSide(color: Theme.of(context).colorScheme.secondary
                          )
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
                            color: Theme.of(context).colorScheme.onPrimary
                          ),
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
                          color: Theme.of(context).colorScheme.onPrimary
                        ),
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary
                    )
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
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.secondary
                          )
                        )
                      )
                    ),
                    onPressed: () async {
                      // AAP document should only be one
                      _selectedAap = await selectSingleFile();
                      _setDisplayAapName(_selectedAap!.names.join());
                      //_setAapUpdated(true);
                    },
                    child: Text(
                      'Select AAP',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.secondary
                      )
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
                              color: Theme.of(context).colorScheme.onPrimary
                            ),
                          ),
                        ),
                      ),
                    ),
                  Visibility(
                    visible: _selectedAap != null,
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
                          color: Theme.of(context).colorScheme.onPrimary
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                          padding: const EdgeInsets.all(17.0),
                          child: FutureBuilder<String>(
                              future: _originalAapName,
                              builder: (BuildContext context, AsyncSnapshot<String> snapshot){
                                if(snapshot.hasData){
                                  return Text(
                                    "original AAP: ${snapshot.data!}",
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimary
                                    ),
                                  );
                                }else if(snapshot.hasError){
                                  return Text(
                                    "original AAP: no AAP found",
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimary
                                    ),
                                  );
                                } else{
                                  return Text(
                                    "Loading",
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimary
                                    ),
                                  );
                                }
                              }
                          )
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
        }
        else {
          controller = _reasonController;
        }

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
    return {'Form': textFormFields, 'Attachments': attachments, 'AAP': aap};
  }

  void initAapNames()async{
    _originalAapName = await getAapFileName(widget.currentUser.studentID);
    print("after init $_originalAapName");
  }

  @override
  void initState() {
    super.initState();
    _originalAapName = getAapFileName(widget.currentUser.studentID);
  subjectList = widget.getSubjectList();

    for (final subject in subjectList) {
      subjectCodeList.add(subject.code);
    }

    selectedSubject = widget.currentSubject;
    assessmentList = widget.currentSubject.assessments;
    assessmentNameList = RequestType.getAssessmentNames(assessmentList);
    //initAapNames();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> form = buildForm(widget.currentUser);
    final List<Widget> textFields = form['Form'];
    final Widget attachments = form['Attachments'];
    final Widget aap = form['AAP'];
    _displayAapName = "";


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
                    icon: const Icon(
                      Icons.close,
                      size: 40.0,
                      color: Colors.white
                    ),
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
            // Attachment part
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

                final request = RequestModel(
                  requestedBy: widget.currentUser.name,
                  requestedByStudentID: widget.currentUser.studentID!,
                  assessedBy: '',
                  assessment: selectedAssessment,
                  reason: _reasonController.text,
                  additionalInfo: _additionalInformationController.text,
                  state: 'Open',
                  databasePath: '',
                  timeSubmitted: DateTime.now(),
                  requestType: selectedRequestType,
                  daysExtending: daysExtending
                );

                final docRef = await dataBase.submitRequest(widget.currentUser, selectedSubject, request);
                request.databasePath = docRef.path;
                request.timeSubmitted = DateTime.now();
                widget.closeNewRequestForm();
                widget.setCurrentSubject(selectedSubject);
                widget.openSubmittedRequest(request);
                widget.incrementCounter();

                // upload selected files
                if(_selectedFiles != null){
                  _uploadTask = uploadFile(docRef.id, _selectedFiles!);
                }
                if(_selectedAap != null){
                  // delete old AAP then upload new AAP
                  clearFolder(widget.currentUser.studentID);
                  uploadFile(widget.currentUser.studentID, _selectedAap!);

                  // TODO: update aapPath for user after uploading aap
                  //_updateUserAapPath("aRTMyP7HK7HV7RgOkMw6");
                }
                // clear all variables\
                _clearFileVariables();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
