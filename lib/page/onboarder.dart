import 'package:flutter/material.dart';
import 'package:specon/models/subject_model.dart';
import 'assessment_manager_page.dart';
import 'permission_manager_page.dart';

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
  var permanButtonEnabled = false;
  var finishButtonEnabled = false;

  bool isPermanButtonEnabled() {
    return permanButtonEnabled;
  }

  bool isFinishButtonEnabled() {
    return finishButtonEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.subject.name,
                  style: const TextStyle(color: Colors.green)),
              Text(widget.subject.code,
                  style: const TextStyle(color: Colors.green)),
              Text(widget.subject.semester,
                  style: const TextStyle(color: Colors.green)),
              Text(widget.subject.year,
                  style: const TextStyle(color: Colors.green)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        permanButtonEnabled = true;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AssessmentManager(
                              subject: widget.subject,
                              refreshFn: setState,
                            ),
                          ),
                        );
                      });
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: const BorderSide(color: Colors.blue, width: 1),
                      )),
                    ),
                    child: const Text('Assessment Manager'),
                  ),
                  TextButton(
                    onPressed: !isPermanButtonEnabled()
                        ? null
                        : () => {
                              setState(() {
                                finishButtonEnabled = true;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PermissionManager(
                                      currentSubject: widget.subject,
                                    ),
                                  ),
                                );
                              })
                            },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: const BorderSide(color: Colors.blue, width: 1),
                      )),
                    ),
                    child: const Text('Permissions Manager'),
                  ),
                  TextButton(
                    onPressed: !isFinishButtonEnabled()
                        ? null
                        : () => {
                              setState(() {
                                Navigator.pop(context);
                              })
                            },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: const BorderSide(color: Colors.blue, width: 1),
                      )),
                    ),
                    child: const Text('Finish'),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
