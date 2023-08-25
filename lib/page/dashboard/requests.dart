/// The requests part of the [Dashboard] page.
///
/// Shows all requests in a list. These are submitted requests for students
/// and received requests for tutors and subject coordinators.

import 'package:flutter/material.dart';

import '../dashboard_page.dart';

class Requests extends StatefulWidget {

  final Function getCurrentSubject;

  const Requests({Key? key, required this.getCurrentSubject}) : super(key: key);

  @override
  State<Requests> createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {

  List<String> filterSelections = [
    "All",
    "Project 1",
    "Project 2",
    "Final Exam",
    "Mid Semester Exam",
  ];

  List allRequests = [
    {"ID": 1, "name": 'Alex', "subject": "COMP30023", "type": "Project 1"},
    {"ID": 2, "name": 'Bob', "subject": "COMP30019", "type": "Project 2"},
    {"ID": 3, "name": 'Aren', "subject": "COMP30022", "type": "Final Exam"},
    {"ID": 4, "name": 'Aden', "subject": "COMP30023", "type": "Mid Semester Exam"},
    {"ID": 5, "name": 'Lo', "subject": "COMP30020", "type": "Project 1"},
    {"ID": 6, "name": 'Harry', "subject": "COMP30019", "type": "Project 2"},
    {"ID": 7, "name": 'Drey', "subject": "COMP30022", "type": "Project 2"},
    {"ID": 8, "name": 'Brian', "subject": "COMP30023", "type": "Final Exam"},
    {"ID": 9, "name": 'David', "subject": "COMP30019", "type": "Project 1"},
    {"ID": 10, "name": 'Po', "subject": "COMP30021", "type": "Project 1"},
    {"ID": 10, "name": 'Po', "subject": "COMP30021", "type": "Project 1"},
    {"ID": 10, "name": 'Po', "subject": "COMP30021", "type": "Project 1"},
    {"ID": 10, "name": 'Po', "subject": "COMP30021", "type": "Project 1"},
    {"ID": 10, "name": 'Po', "subject": "COMP30021", "type": "Project 1"},
    {"ID": 10, "name": 'Po', "subject": "COMP30021", "type": "Project 1"},
    {"ID": 10, "name": 'Po', "subject": "COMP30021", "type": "Project 1"},
    {"ID": 10, "name": 'Po', "subject": "COMP30021", "type": "Project 1"},
    {"ID": 10, "name": 'Po', "subject": "COMP30021", "type": "Project 1"},
    {"ID": 10, "name": 'Po', "subject": "COMP30021", "type": "Project 1"},
  ];

  @override
  void initState() {
    dropdownValue = filterSelections.first;
    super.initState();
  }

  // should get information from canvas
  // List<DropdownMenuItem<String>> filterSelections = [
  //   DropdownMenuItem<String>(child: Text("All"), value: "All",),
  //   DropdownMenuItem<String>(child: Text("Project 1"), value: "Project 1",),
  //   DropdownMenuItem<String>(child: Text("Project 2"), value: "Project 2",),
  //   DropdownMenuItem<String>(child: Text("Final Exam"), value: "Final Exam",),
  //   DropdownMenuItem<String>(child: Text("Mid Semester Exam"), value: "Mid Semester Exam",),
  // ];

  final onPrimary = const Color(0xFFDF6C00);
  final topBarColor = const Color(0xFF385F71);
  final filterContainerColor = Colors.white10;
  final dividerColor = Colors.white30;
  final mainBodyColor = const Color(0xFF333333);
  final requestColor = const Color(0xFFD4D4D4);
  final ScrollController _scrollController = ScrollController();
  String currentSubject = '';
  String dropdownValue = '';
  String searchString = '';
  List _foundRequests = [];

  // First filter
  void _filterBySubject() {

    List filteredBySubject = [];

    if (widget.getCurrentSubject() != currentSubject){
      currentSubject = widget.getCurrentSubject();
      dropdownValue = filterSelections.first;
    }

    for (var request in allRequests) {
      if (request['subject'] == currentSubject) {
        filteredBySubject.add(request);
      }
    }
    setState(() {
      _foundRequests = filteredBySubject;
    });
  }

  // Second filter
  void _filterByAssignment() {

    List filteredByAssignment = [];

    if (dropdownValue != "All") {
      filteredByAssignment = _foundRequests.where((request) =>
          request['type'].contains(dropdownValue)).toList();

    }else{
      filteredByAssignment = _foundRequests.where((request) =>
          request['type'].contains("")).toList();
    }
    setState(() {
      _foundRequests = filteredByAssignment;
    });
  }

  // Third filter
  void _filterBySearch() {

    List searchResult = [];

    if(searchString.isEmpty) {
      searchResult = _foundRequests;

    }else{
      // apply search logic, should change later or not?
      searchResult = _foundRequests.where((request) =>
          request['name'].toLowerCase().contains(searchString.toLowerCase())).toList();
    }
    setState(() {
      _foundRequests = searchResult;
    });
  }

  @override
  Widget build(BuildContext context) {

    _filterBySubject();
    _filterByAssignment();
    _filterBySearch();

    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Column(
            children: [

              // Search Bar
              Padding(

                padding: const EdgeInsets.only(top: 7.0, bottom: 5.0),
                child: SizedBox(

                  height: 45.0,
                  child: TextField(

                    onChanged: (value) {
                      setState(() {
                        searchString = value;
                      });
                    },

                    style: const TextStyle(color: Colors.white),

                    decoration: InputDecoration(

                      labelText: 'Name Search',
                      labelStyle: const TextStyle(color: Colors.white),
                      suffixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: mainBodyColor,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: mainBodyColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: topBarColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Divider(
                color: dividerColor,
                thickness: 3,
                height: 1,
              ),

              // Filter Button
              Container(
                decoration: BoxDecoration(color: filterContainerColor),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  // filter drop down button
                  children: <Widget>[DropdownButton<String>(
                    //dropdownColor: Color(0xFFD4D4D4),
                    iconDisabledColor: mainBodyColor,
                    focusColor: mainBodyColor,

                    style: TextStyle(color: onPrimary, fontSize: 13),
                    padding: const EdgeInsets.all(1),
                    value: dropdownValue,
                    items: filterSelections.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged:(value) {
                      setState(() {
                        dropdownValue = value!;
                      });
                    },
                  ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Divider(
                  color: dividerColor,
                  thickness: 3,
                  height: 1,
                ),
              ),

              // Display requests
              Expanded(
                child: RawScrollbar(
                  controller: _scrollController,
                  thumbColor: Colors.white38,
                  radius: const Radius.circular(20),
                  thickness: 5,
                  child: ListView.builder(
                      itemCount: _foundRequests.length,
                      controller: _scrollController,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: InkWell(
                          onTap: () {},
                          child: Card(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  // request first row
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const SizedBox(width: 4),
                                      const Icon(Icons.album, size: 20.0),
                                      const SizedBox(width: 12),
                                      Text(_foundRequests[index]['name']),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                                  // bottom row
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(width: 8),
                                      Text(_foundRequests[index]['type']),
                                      const SizedBox(width: 8),
                                      const Text('4h'),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}