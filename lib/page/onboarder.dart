import 'package:specon/models/subject_model.dart';

import 'asm_mana.dart';
import 'permission.dart';
import 'package:flutter/material.dart';

class Onboarder extends StatefulWidget {
  final SubjectModel subject;
  const Onboarder({super.key, required this.subject});

  @override
  State<Onboarder> createState() => _OnboarderState();
}

class _OnboarderState extends State<Onboarder> {
  int state = 0; // welcome, assman, perman, done

  void printHi() {
    print('hi');
  }

  bool getStateBool() {
    if (state >= 2) {
      return false;
    } else {
      return true;
    }
  }

  bool assManUnlocked() {
    if (state >= 1) {
      return false;
    } else {
      return true;
    }
  }

  bool perManUnlocked() {
    if (state >= 2) {
      return false;
    } else {
      return true;
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
            Text('Current State: $state'),
            SizedBox(height: 20),
            MaterialButton(
              onPressed: () {
                setState(() {
                  state += 1;
                });
              },
              child: Text('Increment State'),
            ),
            // Assessment Manager Button
            MaterialButton(
              onPressed: assManUnlocked()
                  ? null
                  : () => setState(() {
                        state += 1;
                        if (state == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AsmManager(
                                  subject: widget.subject, refreshFn: setState),
                            ),
                          );
                        } else if (state == 2) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Permission(),
                            ),
                          );
                        }
                      }),
              child: Text('Ass Manager'),
            ),
            MaterialButton(
              onPressed: () {},
              child: Text('Permission Manager'),
            ),
            MaterialButton(
              onPressed: getStateBool() ? null : () => state += 1,
              //onPressed: state >= 1 ? printHi() : null,
              child: Text('Finish'),
            ),
            OutlinedButton(
                //onPressed: calculateWhetherDisabledReturnsBool() ? null : () => whatToDoOnPressed,
                onPressed: getStateBool() ? null : () => state += 1,
                child: Text('Other'))
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
