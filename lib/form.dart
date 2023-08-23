import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const List<String> fieldTitles = [
    "Given Name",
    "Last Name",
    "Email",
    "Student ID",
    "Subject"
  ];

  List<Widget> buildColumn(List<String> fields) {
    List<Widget> textFormFields = [];
    for (int i = 0; i < fields.length; i++) {
      textFormFields.add(
        TextFormField(
          cursorColor: const Color(0xFFD4D4D4),
          decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xFFD4D4D4),
                width: 0.5,
              ),
            ),
            floatingLabelStyle:
                TextStyle(color: Color(0xFFD4D4D4), fontSize: 22),
            labelText: fieldTitles[i],
            labelStyle: TextStyle(color: Color(0xFFD4D4D4), fontSize: 18),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xFFD78521),
                width: 1,
              ),
            ),
          ),
          style: const TextStyle(color: Color(0xFFD4D4D4)),
        ),
      );

      textFormFields.add(const SizedBox(height: 15));
    }

    return textFormFields;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...buildColumn(fieldTitles),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: const Color(0xFF333333),

    );
  }
}
/*
class StudentInformationForm extends StatelessWidget {
  const StudentInformationForm({super.key});

  TextFormField build(BuildContext context, String fieldName) {
    return TextFormField(
      cursorColor: const Color(0xFFD4D4D4),
      decoration: const InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFD4D4D4),
            width: 0.5,
          ),
        ),
        floatingLabelStyle: TextStyle(color: Color(0xFFD4D4D4), fontSize: 22),
        labelText: 'Name',
        labelStyle: TextStyle(color: Color(0xFFD4D4D4), fontSize: 18),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFD78521),
            width: 1,
          ),
        ),
      ),
      style: const TextStyle(color: Color(0xFFD4D4D4)),
    );
  }
}
*/