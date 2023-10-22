
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:specon/models/request_type.dart';
import 'package:specon/models/subject_model.dart';
import '../models/user_model.dart';

import '../db.dart';
import '../models/request_model.dart';
import 'package:specon/storage.dart';

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
    return

  }
}