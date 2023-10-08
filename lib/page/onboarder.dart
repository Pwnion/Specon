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
                  // Increment the state when the button is clicked
                  state += 1;
                  if (state == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AsmManager(
                          subject: widget.subject,
                          refreshFn: setState,
                        ),
                      ),
                    );
                  } else if (state == 2) {}
                });
              },
              child: Text('Increment State'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final assessmentManager =
        AsmManager(subject: widget.subject, refreshFn: setState);
    const permissionManager = Permission();
  }
}
