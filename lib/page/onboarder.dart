
import 'package:flutter/material.dart';
import 'package:specon/models/subject_model.dart';
import 'assessment_manager_page.dart';
import 'permission_manager_page.dart';

class Onboarder extends StatefulWidget {

  final SubjectModel subject;

  const Onboarder( {
    super.key,
    required this.subject
  });


  @override
  State<Onboarder> createState() => _OnboarderState();
}

class _OnboarderState extends State<Onboarder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          Text(widget.subject.name, style: const TextStyle(color: Colors.green)),
          Text(widget.subject.code, style: const TextStyle(color: Colors.green)),
          Text(widget.subject.semester, style: const TextStyle(color: Colors.green)),
          Text(widget.subject.year, style: const TextStyle(color: Colors.green)),

          TextButton(onPressed: () {
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
            });
          }, child: const Text('Assessment Manager')),

          TextButton(onPressed: () {
            setState(() {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PermissionManager(
                    currentSubject: widget.subject,
                  ),
                ),
              );
            });
          }, child: const Text('Permissions Manager')),


        ],

      ),
    );
  }
}