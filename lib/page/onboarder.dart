import 'package:flutter/material.dart';
import 'package:specon/models/subject_model.dart';
import 'assessment_manager_page.dart';
import 'permission_manager_page.dart';
import 'package:specon/db.dart';

class Onboarder extends StatefulWidget {
  final SubjectModel subject;

  const Onboarder({
    Key? key,
    required this.subject,
  }) : super(key: key);

  @override
  State<Onboarder> createState() => _OnboarderState();
}

class _OnboarderState extends State<Onboarder> {
  bool _permanButtonEnabled = false;
  bool _finishButtonEnabled = false;
  static final _db = DataBase();

  bool _isPermanButtonEnabled() {
    return _permanButtonEnabled;
  }

  bool _isFinishButtonEnabled() {
    return _finishButtonEnabled;
  }

  void test() async {
    List<String>? a = await _db.importFromCanvas(widget.subject.code);
    print(a);
  }

  void _refreshFnAsmMan() {
    _permanButtonEnabled = true;
    setState(() {});
  }

  void _refreshFnPerMan() {
    _finishButtonEnabled = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: BackButton(
          color: Theme.of(context).colorScheme.surface,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Text(
            "Subject Onboarding",
            style: TextStyle(
              color: Theme.of(context).colorScheme.surface,
              fontSize: 18,
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome, Subject Coordinator!",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Subject Initialization:",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "To ensure a smooth start for the upcoming semester, please complete the following steps to initialize assessments and roles for the subject.",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "1. Confirm Subject detail:",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Please make sure the following details are correct. If not, please contact the support team.",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Subject Name: ${widget.subject.name}",
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                ),
              ),
              Text(
                "Subject Code: ${widget.subject.code}",
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                ),
              ),
              Text(
                "Subject Semester: ${widget.subject.semester}",
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                ),
              ),
              Text(
                "Subject Year: ${widget.subject.year}",
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "2. Initialize Assessments:",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "To set up assessments for this subject, click the \"Assessment Manager\" button. Inside the manager, define assessments and click import.",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "3. Assign Roles:",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "To define roles associated with this subject, click the \"Role Manager\" button. Inside the manager, specify role names and click the \"+\" button after each entry.",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Thank you for your cooperation in preparing for the upcoming semester!",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      test();
                      setState(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AssessmentManager(
                              subject: widget.subject,
                              refreshFn: setState,
                              onboardRefreshFn: _refreshFnAsmMan,
                            ),
                          ),
                        );
                      });
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Assessment Manager',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 5),
                  TextButton(
                    onPressed: !_isPermanButtonEnabled()
                        ? null
                        : () => {
                              setState(() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PermissionManager(
                                      currentSubject: widget.subject,
                                      onBoarderRefreshFn: _refreshFnPerMan,
                                    ),
                                  ),
                                );
                              })
                            },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 1,
                          ),
                        ),
                      ),
                      textStyle: MaterialStateProperty.all(
                        const TextStyle(color: Colors.white),
                      ),
                    ),
                    child: Text(
                      'Permissions Manager',
                      style: _isPermanButtonEnabled()
                          ? const TextStyle(color: Colors.white)
                          : const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 5),
                  TextButton(
                    onPressed: !_isFinishButtonEnabled()
                        ? null
                        : () => {
                              setState(() {
                                Navigator.pop(context);
                              })
                            },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 1,
                          ),
                        ),
                      ),
                      textStyle: MaterialStateProperty.all(
                        const TextStyle(color: Colors.lime),
                      ),
                    ),
                    child: Text(
                      'Finish',
                      style: _isFinishButtonEnabled()
                          ? const TextStyle(color: Colors.white)
                          : const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
