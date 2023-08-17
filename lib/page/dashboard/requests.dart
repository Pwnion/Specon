/// The requests part of the [Dashboard] page.
///
/// Shows all requests in a list. These are submitted requests for students
/// and received requests for tutors and subject coordinators.

import 'package:flutter/material.dart';

import '../dashboard_page.dart';

class Requests extends StatefulWidget {
  const Requests({Key? key}) : super(key: key);

  @override
  State<Requests> createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}