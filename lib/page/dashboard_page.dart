/// The main page for an authenticated user.
///
/// Content changes based on the [UserType] that is authenticated.
/// Authors: Kuo Wei WU (Brian), Zhi Xiang CHAN (Lucas), Aden MCCUSKER, Jeremy ANNAL, Hung Long NGUYEN (Drey)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

class _DashboardState extends State<Dashboard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  SubjectModel currentSubject = SubjectModel(
      name: '',
      code: '',
      assessments: [],
      semester: '',
      year: '',
      databasePath: '');
  List<SubjectModel> subjectList = [];
  Map<String, dynamic> currentRequest = {};
  bool newRequest = false;
  bool showSubmittedRequest = false;
  Widget? requestWidget;

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final _database = DataBase();
  final Future<UserModel> _userFromDB =
      _database.getUserFromEmail(_auth.currentUser!.email!);

  /// Function that opens a submitted request in column 3, closes any new request form, TODO: will need to change param to RequestModel
  void openSubmittedRequest(Map<String, dynamic> currentRequest) {
    setState(() {
      showSubmittedRequest = true;
      newRequest = false;
      this.currentRequest = currentRequest;
    });
  }

  /// Function that opens a new request form, closes any submitted request that was shown in column 3
  void openNewRequestForm() {
    setState(() {
      newRequest = true;
      showSubmittedRequest = false;
    });
  }

  /// Getter for current selected request in column 2, TODO: will need to change return type to RequestModel
  Map<String, dynamic> getCurrentRequest() => currentRequest;

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

  /// Getter for user's enrolled subjects
  void setSubjectList(List<SubjectModel> subjects) {
    setState(() {
      subjectList = subjects;
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
          getCurrentRequest: getCurrentRequest,
          currentUser: currentUser,
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
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
        future: _userFromDB,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final currentUser = snapshot.data!;
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
                    if (currentUser.role == UserType.subjectCoordinator)
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
                    if (currentUser.role == UserType.subjectCoordinator)
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
                          child: Text(currentUser.firstName[0],
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
                        setSubjectList: setSubjectList,
                        currentUser: currentUser,
                        currentSubject: currentSubject,
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
                          currentUser: currentUser),
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
                ]));
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
