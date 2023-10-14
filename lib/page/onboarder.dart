import 'package:specon/models/subject_model.dart';

import 'asm_mana.dart';
import 'permission.dart';
import 'package:flutter/material.dart';
import 'db.dart';

class Onboarder extends StatefulWidget {
  final SubjectModel subject;
  const Onboarder({super.key, required this.subject});

  @override
  State<Onboarder> createState() => _OnboarderState();
}

class _OnboarderState extends State<Onboarder> {
  int state = 0; // welcome, assman, perman, done

  static final dataBase = DataBase();
  late final String docRef;

  bool infoCorrectUnlocked() {
    if (state > 0) {
      return true;
    } else {
      return false;
    }
  }

  bool assManUnlocked() {
    if (state < 1) {
      return true;
    } else {
      return false;
    }
  }

  bool perManUnlocked() {
    if (state < 2) {
      return true;
    } else {
      return false;
    }
  }

  bool isFinishedUnlocked() {
    if (state < 3) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Onboarder Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('subject name: ${widget.subject.name}'),
            Text('subject code: ${widget.subject.code}'),
            Text('subject semester: ${widget.subject.semester}'),
            Text('subject year: ${widget.subject.year}'),
            SizedBox(height: 20),
            MaterialButton(
              onPressed: infoCorrectUnlocked()
                  ? null
                  : () => setState(() {
                        state += 1;
                        dataBase.addSubject(widget.subject);
                      }),
              child: Text('Is this information correct?'),
            ),
            // Assessment Manager Button
            MaterialButton(
              onPressed: assManUnlocked()
                  ? null
                  : () => setState(() {
                        state += 1;
                        if (state >= 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => AsmManager(
                                      subject: widget.subject,
                                      refreshFn: setState,
                                    )),
                          );
                        }
                      }),
              child: Text('Ass Manager'),
            ),
            MaterialButton(
              onPressed: perManUnlocked()
                  ? null
                  : () => setState(() {
                        state += 1;
                        if (state >= 2) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Permission(),
                            ),
                          );
                        }
                      }),
              child: Text('Permission Manager'),
            ),
            MaterialButton(
              onPressed: isFinishedUnlocked() ? null : () => state += 1,
              child: Text('Finish'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
