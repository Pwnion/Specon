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
  late bool permanButtonEnabled = false; // Declare as class variable
  late bool finishButtonEnabled = false; // Declare as class variable

  bool isPermanButtonEnabled() {
    return permanButtonEnabled;
  }

  bool isFinishButtonEnabled() {
    return finishButtonEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          leading: BackButton(
            color: Theme.of(context).colorScheme.surface,
            onPressed: () {
              // Navigate back to the previous screen.
              Navigator.pop(context);
            },
          ),
          title: Center(
            child: Text(
              "Welcome 🎉",
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
                fontSize: 50,
              ),
            ),
          ),
        ),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AssessmentManager(
                              subject: widget.subject,
                              refreshFn: setState,
                            ),
                          ),
                        );
                        if (widget.subject.assessments.isNotEmpty) {
                          permanButtonEnabled = true;
                        }
                      });
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 1),
                      )),
                    ),
                    child: const Text(
                      'Assessment Manager',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 5),
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
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 1),
                      )),
                      textStyle: MaterialStateProperty.all(
                          const TextStyle(color: Colors.white)),
                    ),
                    child: Text(
                      'Permissions Manager',
                      style: isPermanButtonEnabled()
                          ? TextStyle(color: Colors.white)
                          : TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 5),
                  TextButton(
                    onPressed: !isFinishButtonEnabled()
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
                              width: 1),
                        ),
                      ),
                      textStyle: MaterialStateProperty.all(
                          const TextStyle(color: Colors.lime)),
                    ),
                    child: Text(
                      'Finish',
                      style: isFinishButtonEnabled()
                          ? TextStyle(color: Colors.white)
                          : TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
