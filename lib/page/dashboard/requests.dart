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

enum FilterType {subject, assignment}
List<String> filterSelections = [
  "All",
  "Project 1",
  "Project 2",
  "Final Exam",
  "Mid Semester Exam",
];

class _RequestsState extends State<Requests> {
  // for testing
  List<Map<String, dynamic>> allRequests = [
    {"ID": 1, "name": 'Alex', "subject": "COMP30023", "type": "Project 1"},
    {"ID": 2, "name": 'Bob', "subject": "COMP30024", "type": "Project 2"},
    {"ID": 3, "name": 'Aren', "subject": "COMP30024", "type": "Final Exam"},
    {"ID": 4, "name": 'Aden', "subject": "COMP30024", "type": "Mid Semester Exam"},
    {"ID": 5, "name": 'Lo', "subject": "COMP30024", "type": "Project 1"},
    {"ID": 6, "name": 'Harry', "subject": "COMP30024", "type": "Project 2"},
    {"ID": 7, "name": 'Drey', "subject": "COMP30024", "type": "Project 2"},
    {"ID": 8, "name": 'Brian', "subject": "COMP30024", "type": "Final Exam"},
    {"ID": 9, "name": 'David', "subject": "COMP30024", "type": "Project 1"},
    {"ID": 10, "name": 'Po', "subject": "COMP30024", "type": "Project 1"},
  ];
  // should get information from canvas
  // List<DropdownMenuItem<String>> filterSelections = [
  //   DropdownMenuItem<String>(child: Text("All"), value: "All",),
  //   DropdownMenuItem<String>(child: Text("Project 1"), value: "Project 1",),
  //   DropdownMenuItem<String>(child: Text("Project 2"), value: "Project 2",),
  //   DropdownMenuItem<String>(child: Text("Final Exam"), value: "Final Exam",),
  //   DropdownMenuItem<String>(child: Text("Mid Semester Exam"), value: "Mid Semester Exam",),
  // ];

  List<Map<String, dynamic>> _foundRequests = [];
  List<Map<String, dynamic>> _filtered_S_Requests = [];
  List<Map<String, dynamic>> _filtered_A_Requests = [];

  @override
  void initState() {
    _foundRequests = allRequests;
    _filtered_S_Requests = allRequests; // 1st layer filter, Subject
    _filtered_A_Requests = allRequests; // 2nd layer filter, Assignment
    super.initState();
  }
  // function that updates _foundRequests when search, search in 2nd layer filter
  void _searchRequest(String searchString){
    List<Map<String, dynamic>> result = [];
    if(searchString.isEmpty) {
      result = _filtered_A_Requests;
    }else{
      // apply search logic, should change later or not?
      result = _filtered_A_Requests.where((request) =>
          request['name'].toLowerCase().contains(searchString.toLowerCase())).toList();
    }
    setState(() {
      _foundRequests = result;
    });
  }
  // filter out requests whenever we change filter type
  void filterCallback(String value, FilterType type){
    List<Map<String, dynamic>> result = [];

    if (value != "All") {
      if(type == FilterType.assignment){
        result = _filtered_S_Requests.where((request) =>
            request['type'].contains(value)).toList();
        _filtered_A_Requests = result;
      }
      if(type == FilterType.subject){
        // should get called in dashboard (selection is in first column)
      }
    }else{
      if(type == FilterType.assignment){
        result = _filtered_S_Requests.where((request) =>
            request['type'].contains("")).toList();
        _filtered_A_Requests = result;
      }
      if(type == FilterType.subject){
        result = allRequests.where((request) =>
            request['subject'].contains("")).toList();
        _filtered_S_Requests = result;
      }
    }
    setState(() {
      _foundRequests = result;
    });
  }

  String dropdownValue = filterSelections.first;
  @override
  Widget build(BuildContext context) {

<<<<<<< HEAD
    return Scaffold(
      //backgroundColor: Color(0xFF333333),
=======
      return Scaffold(
        //backgroundColor: Color(0xFF333333),
>>>>>>> dashboard-request-and-discussion-
        body: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Column(
            children: [
              // search bar is here
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) => _searchRequest(value),
                  style: const TextStyle(color: Color(0xFFD4D4D4)),
                  cursorColor: const Color(0xFFD4D4D4),
                  //cursorHeight: 15,
                  decoration: const InputDecoration(
<<<<<<< HEAD
                      labelText: '  Search Name', suffixIcon: Icon(Icons.search),
                      iconColor: Color(0xFFD4D4D4),
                      hoverColor: Color(0xFFDF6C00),
                      labelStyle: TextStyle(color: Color(0xFFD4D4D4), fontSize: 10, wordSpacing: 2.0),
                      focusedBorder: OutlineInputBorder( borderSide: BorderSide(color: Color(0xFFD4D4D4), width: 0.3))
=======
                    labelText: '  Search Name', suffixIcon: Icon(Icons.search),
                    iconColor: Color(0xFFD4D4D4),
                    hoverColor: Color(0xFFDF6C00),
                    labelStyle: TextStyle(color: Color(0xFFD4D4D4), fontSize: 10, wordSpacing: 2.0),
                    focusedBorder: OutlineInputBorder( borderSide: BorderSide(color: Color(0xFFD4D4D4), width: 0.3))
>>>>>>> dashboard-request-and-discussion-

                  ),
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  // filter drop down button
                  children: <Widget>[DropdownButton<String>(
                    //dropdownColor: Color(0xFFD4D4D4),
                    iconDisabledColor: Color(0xFF333333), // need this
                    focusColor: Color(0xFF333333),

                    style: const TextStyle(color: Color(0xFFDF6C00), fontSize: 13),
<<<<<<< HEAD
                    padding: const EdgeInsets.all(1),
                    value: dropdownValue,
                    items: filterSelections.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged:(String? value) {
                      filterCallback(value!, FilterType.assignment);
                      setState(() {
                        dropdownValue = value!;
                      });
                    },
=======
                      padding: const EdgeInsets.all(1),
                      value: dropdownValue,
                      items: filterSelections.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged:(String? value) {
                        filterCallback(value!, FilterType.assignment);
                        setState(() {
                          dropdownValue = value!;
                        });
                      },
>>>>>>> dashboard-request-and-discussion-
                  ),
                  ],
                ),
              ),

              Expanded(
                // viewing all request
                child: Container(
                  child: ListView.builder(
                    itemCount: _foundRequests.length,
<<<<<<< HEAD
                    itemBuilder: (context, index) => Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            // request first row
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const SizedBox(width: 4),
                                Icon(Icons.album, size: 20.0,),
                                const SizedBox(width: 12),
                                Text(_foundRequests[index]["name"]),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10, bottom: 10),
                            // bottom row
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 8),
                                Text(_foundRequests[index]["type"]),
                                const SizedBox(width: 8),
                                Text('4h'),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
=======
                      itemBuilder: (context, index) => Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              // request first row
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const SizedBox(width: 4),
                                  Icon(Icons.album, size: 20.0,),
                                  const SizedBox(width: 12),
                                  Text(_foundRequests[index]["name"]),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              // bottom row
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                               children: [
                                 const SizedBox(width: 8),
                                 Text(_foundRequests[index]["type"]),
                                  const SizedBox(width: 8),
                                  Text('4h'),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
>>>>>>> dashboard-request-and-discussion-

                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}