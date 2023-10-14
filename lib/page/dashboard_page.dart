/// The main page for an authenticated user.
///
/// Content changes based on the [UserType] that is authenticated.
/// Authors: Kuo Wei WU (Brian), Zhi Xiang CHAN (Lucas), Aden MCCUSKER, Jeremy ANNAL, Hung Long NGUYEN (Drey)

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
  final UserType userType;

  const Dashboard({Key? key, required this.userType}) : super(key: key);

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

  RequestModel currentRequest = RequestModel(requestedBy: '', reason: '', additionalInfo: '', assessedBy: '', assessment: '', state: '', requestedByStudentID: '', databasePath: '');
  bool newRequest = false;
  bool showSubmittedRequest = false;
  Widget? requestWidget;
  String selectedAssessment = '';
  String role = '';

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


  void getSelectedAssessment(String assessment) {
    setState(() {
      selectedAssessment = assessment;
    });
  }

  /// Function that opens a new request form, closes any submitted request that was shown in column 3
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

  /// Getter for user's enrolled subjects
  List<SubjectModel> getSubjectList() => subjectList;

  /// Function that closes new request form that was shown in column 3
  void closeNewRequestForm() {
    setState(() {
      newRequest = false;
    });
  }

  /// Setter for current selected subject in column 1, refreshes column 2, and closes any submitted request that was shown in column 3
  void setCurrentSubject(SubjectModel subject) {
    setState(() {
      currentSubject = subject;
      requestWidget;
      showSubmittedRequest = false;
    });
  }

  ///
  void setRole(SubjectModel subject, UserModel user){
    setState(() {
      role = subject.roles[user.id]!;
    });
  }

  /// Getter for user's enrolled subjects
  void setSubjectList(List<SubjectModel> subjects) {
    setState(() {
      subjectList = subjects; // TODO: setstate called after dispose error
    });
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
      );
    }
    // Show a submitted request's details
    else if (showSubmittedRequest) {
      return Center(
        child: Discussion(
          currentRequest: currentRequest,
          currentUser: currentUser,
          role: role,
        ),
      );
    }
    // Nothing is selected, show 'select a request'
    else {
      return Center(
        child: Text('Select a request',
            style: TextStyle(
                color: Theme.of(context).colorScheme.surface, fontSize: 25)),
      );
    }
  }


  @override
  void initState() {
    _database.getUserFromEmail(_auth.currentUser!.email!).then((user) {
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
                                  builder: (_) => const Permission()));
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
                      child: const Text('Logout'),
                      onTap: () => _auth.signOut(),
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
