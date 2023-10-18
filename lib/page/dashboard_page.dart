/// The main page for an authenticated user.
///
/// Content changes based on the [UserType] that is authenticated.
/// Authors: Kuo Wei Wu, Zhi Xiang CHAN (Lucas)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:specon/models/request_model.dart';
import 'package:specon/page/db.dart';
import 'package:specon/specon_form.dart';
import 'package:specon/page/asm_mana.dart';
import 'package:specon/page/dashboard/navigation.dart';
import 'package:specon/page/dashboard/requests.dart';
import 'package:specon/page/dashboard/discussion.dart';
import 'package:specon/page/permission.dart';
import 'package:specon/user_type.dart';
import 'package:specon/models/subject_model.dart';
import 'package:specon/models/user_model.dart';

class Dashboard extends StatefulWidget {
  final String? canvasEmail;
  final void Function()? canvasLogout;
  final UserType userType;

  const Dashboard(
    {
      Key? key,
      this.canvasEmail,
      this.canvasLogout,
      required this.userType
    }
  ) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  SubjectModel currentSubject = SubjectModel(
      name: '',
      code: '',
      assessments: [],
      semester: '',
      year: '',
      databasePath: '',
      roles: {});

  RequestModel currentRequest = RequestModel.emptyRequest;
  bool newRequest = false;
  bool showSubmittedRequest = false;
  Widget? requestWidget;
  String selectedAssessment = '';
  String role = '';
  int counter = 0;
  final studentIDController = TextEditingController();
  final studentIDFormKey = GlobalKey<FormState>();
  final confirmStudentIDFormKey = GlobalKey<FormState>();
  static const int minStudentIdLen = 7;

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final _database = DataBase();

  late final UserModel currentUser;
  late final List<SubjectModel> subjectList;
  bool fetchingFromDB = true;

  /// Function that opens a submitted request in column 3, closes any new request form, TODO: will need to change param to RequestModel
  void openSubmittedRequest(RequestModel request) {
    setState(() {
      showSubmittedRequest = true;
      newRequest = false;
      currentRequest = request;
    });
  }

  /// Function that increments a counter each time a new request has been
  /// submitted, or a request's state has been changed, to refresh column 2
  void incrementCounter() => setState(() => counter++);

  /// Setter for current selected assessment in column 1
  void setSelectedAssessment(String assessment) {
    setState(() {
      selectedAssessment = assessment;
    });
  }

  /// Function that opens a new request form, closes any submitted request that
  /// was shown in column 3
  void openNewRequestForm() {
    setState(() {
      newRequest = true;
      showSubmittedRequest = false;
    });
  }

  /// Getter for current selected request in column 2,
  RequestModel getCurrentRequest() => currentRequest;

  /// Getter for current selected subject in column 1
  SubjectModel getCurrentSubject() => currentSubject;

  /// Getter for current selected assessment of a subject in column 1
  String getSelectedAssessment() => selectedAssessment;

  /// Getter for user's enrolled subjects
  List<SubjectModel> getSubjectList() => subjectList;

  /// Function that closes new request form that was shown in column 3
  void closeNewRequestForm() => setState(() => newRequest = false);

  /// Function that closes the submitted request that was shown in column 3
  void closeSubmittedRequest() {
    setState(() {
      showSubmittedRequest = false;
      currentRequest = RequestModel.emptyRequest;
    });
  }

  /// Setter for current selected subject in column 1, refreshes column 2, and
  /// closes any submitted request that was shown in column 3
  void setCurrentSubject(SubjectModel subject) {
    setState(() {
      currentSubject = subject;
      requestWidget;
      showSubmittedRequest = false;
      currentRequest = RequestModel.emptyRequest;
    });
  }

  /// Setter for the user's role in a subject
  void setRole(SubjectModel subject, UserModel user) async {
    setState(() {
      role = subject.roles[user.id]!;
    });

    // If user is a student, and no student ID is found, prompt a popup
    if(UserTypeUtils.convertString(role) == UserType.student && currentUser.studentID.isEmpty) {
      askForStudentIDPopUp().then((value) {
        _database.setStudentID(value!);
        setState(() {
          currentUser.studentID = value;
        });
      });
    }

  }

  /// Function that builds a dialog to prompt a student to enter student ID
  Future<String?> askForStudentIDPopUp() {

    return showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setState) => AlertDialog(
          title: Text(
              "Please enter your Student ID",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.surface
              )
          ),
          content: SizedBox(
            width: 100.0,
            height: 170.0,
            child: Column(
              children: [
                // Enter StudentID
                Form(
                  key: studentIDFormKey,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your student id';
                      } else if (value.length < minStudentIdLen) {
                        return 'Please enter a valid student id';
                      }
                      return null;
                    },
                    enableInteractiveSelection: false,
                    controller: studentIDController,
                    style: const TextStyle(color: Colors.white54), // TODO: Color theme
                    cursorColor: Theme.of(context).colorScheme.onSecondary,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onSecondary,
                          width: 0.5,
                        ),
                      ),
                      labelText: 'Student ID',
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
                const SizedBox(height: 15.0),
                // Confirm StudentID
                Form(
                  key: confirmStudentIDFormKey,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your student id again';
                      }
                      else if (value != studentIDController.text) {
                        return 'Student id does not match the one entered above,\n please enter again';
                      }
                      return null;
                    },
                    enableInteractiveSelection: false,
                    style: const TextStyle(color: Colors.white54), // TODO: Color theme
                    cursorColor: Theme.of(context).colorScheme.onSecondary,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onSecondary,
                          width: 0.5,
                        ),
                      ),
                      labelText: 'Confirm Student ID',
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
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {

                if (!studentIDFormKey.currentState!.validate() ||
                    !confirmStudentIDFormKey.currentState!.validate()) {
                  return;
                }
                Navigator.pop(context, studentIDController.text);
                studentIDController.clear();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      )
    );
  }

  /// Function that determines which widget should be display in column 3
  Widget displayThirdColumn(UserModel currentUser) {
    // Show new Request Form
    if (newRequest) {
      return SpeconForm(
        closeNewRequestForm: closeNewRequestForm,
        currentUser: currentUser,
        currentSubject: currentSubject,
        getSubjectList: getSubjectList,
        setCurrentSubject: setCurrentSubject,
        openSubmittedRequest: openSubmittedRequest,
        incrementCounter: incrementCounter,
      );
    }
    // Show a submitted request's details
    else if (showSubmittedRequest) {
      return Center(
        child: Discussion(
          currentRequest: currentRequest,
          currentUser: currentUser,
          role: role,
          subjectCode: currentSubject.code,
          incrementCounter: incrementCounter,
          closeSubmittedRequest: closeSubmittedRequest,
        ),
      );
    }
    // Nothing is selected, show 'select a request'
    else {
      return Center(
        child: Text('Select a request',
          style: TextStyle(
            color: Theme.of(context).colorScheme.surface, fontSize: 25
          )
        ),
      );
    }
  }


  @override
  void initState() {
    _database.getUserFromEmail(
      _auth.currentUser != null ? _auth.currentUser!.email! : widget.canvasEmail!
    ).then((user) {
      _database.getEnrolledSubjects().then((subjects) {
        if(!mounted) return;
        setState(() {
          subjectList = subjects;
          currentUser = user;
          fetchingFromDB = false;
        });

      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if (!fetchingFromDB){
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 0.0,
            // Logo
            leading: InkWell(
                onTap: () {},
                child: const Center(
                    child: Text(
                      'Specon',
                      style: TextStyle(
                          fontSize: 25.0, fontWeight: FontWeight.bold),
                    ))),
            leadingWidth: 110.0,
            // Subject code and name title
            title: Text('${currentSubject.code} - ${currentSubject.name}',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                    fontSize: 20.0)),
            centerTitle: true,
            actions: [
              // Home Button
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: InkWell(
                  onTap: () {},
                  child: const Icon(
                    Icons.home,
                    size: 30.0,
                  ),
                ),
              ),
              // Assessment Manager Button
              if (role == 'subject_coordinator')
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => AsmManager(
                                subject: currentSubject,
                                refreshFn: setState,
                              )));
                    },
                    child: const Icon(
                      Icons.document_scanner,
                      size: 30.0,
                    ),
                  ),
                ),
              // Permission Settings Button
              if (role == 'subject_coordinator')
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: Tooltip(
                    message: 'Permission Settings',
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Permission(
                                currentSubject: currentSubject
                              )
                            )
                          );
                        });
                      },
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 30.0,
                      ),
                    ),
                  ),
                ),
              // Notification Button
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: InkWell(
                  onTap: () {},
                  child: const Icon(
                    Icons.notifications,
                    size: 30.0,
                  ),
                ),
              ),
              // Avatar Button
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: PopupMenuButton(
                  itemBuilder: (BuildContext context) => [

                    PopupMenuItem(
                      enabled: false,
                      onTap: () {},
                      child: Text(
                        currentUser.email,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),

                    PopupMenuItem(
                      child: const Text('Logout'),
                      onTap: () {
                        if(widget.canvasEmail != null) {
                          widget.canvasLogout!();
                        } else {
                          _auth.signOut();
                        }
                      },
                    ),
                  ],
                  tooltip: 'User Options',
                  iconSize: 50,
                  icon: CircleAvatar(
                    backgroundColor:
                    Theme.of(context).colorScheme.secondary,
                    child: Text(currentUser.name[0],
                        style: TextStyle(
                            color:
                            Theme.of(context).colorScheme.surface)),
                  ),
                ),
              ),
            ],
          ),
          body: Stack(children: [
            Row(children: [
              // Dashboard column 1
              SizedBox(
                width: 150.0,
                child: Navigation(
                  openNewRequestForm: openNewRequestForm,
                  setCurrentSubject: setCurrentSubject,
                  subjectList: subjectList,
                  currentUser: currentUser,
                  currentSubject: currentSubject,
                  setSelectedAssessment: setSelectedAssessment,
                  getSelectedAssessment: getSelectedAssessment,
                  role: role,
                  setRole: setRole,
                ),
              ),
              // Divider
              VerticalDivider(
                color: Theme.of(context).colorScheme.surface,
                thickness: 1,
                width: 1,
              ),
              // Dashboard column 2
              SizedBox(
                width: 300.0,
                child: requestWidget = Requests(
                  getCurrentSubject: getCurrentSubject,
                  openSubmittedRequest: openSubmittedRequest,
                  currentUser: currentUser,
                  selectedAssessment: selectedAssessment,
                  role: UserTypeUtils.convertString(role),
                  counter: counter,
                  selectedRequest: currentRequest,
                ),
              ),
              // Divider
              VerticalDivider(
                color: Theme.of(context).colorScheme.surface,
                thickness: 1,
                width: 1,
              ),
              // Dashboard column 3
              Expanded(
                child: displayThirdColumn(currentUser),
              ),
            ]),
          ]
        )
      );
    }
    else {
      return const SizedBox(
        height: 100.0,
        width: 100.0,
        child: Center(child: CircularProgressIndicator()),
      );
    }
  }
}
