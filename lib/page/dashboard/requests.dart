/// The requests part of the [Dashboard] page.
///
/// Shows all requests in a list. These are submitted requests for students
/// and received requests for tutors and subject coordinators.

import 'package:flutter/material.dart';
import 'package:specon/backend.dart';
import 'package:specon/user_type.dart';

class Requests extends StatefulWidget {

  final Function getCurrentSubject;
  final Function openSubmittedRequest;
  final Map currentUser; //whats this for
 // void Function approveRequest(int requestID){};

  const Requests(
      {
        Key? key,
        required this.getCurrentSubject,
        required this.openSubmittedRequest,
        required this.currentUser
      }
      ) : super(key: key);

  @override
  State<Requests> createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {

  // TODO: Get assignments from canvas and it should be customisable
  List<String> filterSelections = BackEnd().getAssessments('subjectID');  // TODO: where to call

  // TODO: Get all requests from the database
  List allRequests = BackEnd().getAllRequest('subjectID');  // TODO: where to call

  final onPrimary = const Color(0xFFDF6C00);
  final topBarColor = const Color(0xFF385F71);
  final filterContainerColor = Colors.white10;
  final dividerColor = Colors.white30;
  final mainBodyColor = const Color(0xFF333333);
  final requestColor = const Color(0xFFD4D4D4);
  final _scrollController = ScrollController();
  final nameSearchController = TextEditingController();
  String currentSubject = ''; // Get from dashboard
  String dropdownValue = '';
  String searchString = '';
  List _foundRequests = []; // result showing on screen
  List filteredByUserType = []; // request through user
  List filteredBySubject = []; // request through user & subject
  List filteredByAssignment = []; // request through user, subject & assignment (for search)
  Map currentUser = {}; // Get from dashboard


  // Second filter
  void _filterBySubject() {

    if (widget.getCurrentSubject() != currentSubject){
      currentSubject = widget.getCurrentSubject();
      dropdownValue = filterSelections.first;
      nameSearchController.clear();
      searchString = '';
    }

    filteredBySubject = [];
    for (var request in filteredByUserType) {
      if (request['subject'] == currentSubject) {
        filteredBySubject.add(request);
      }
    }
    //_foundRequests = filteredBySubject;
  }

  // First filter
  void _filterByUserType() {

    //List filteredByUserType = [];
    UserType currentUserType = currentUser['userType'];

    // Only show the student's request
    if (currentUserType == UserType.student) {
      //for (var request in allRequests) {
        // if (request['submittedBy'] == currentUser['userID']) {
        //   filteredByUserType.add(request);
        // }
        filteredByUserType = allRequests.where((request) =>
            request['submittedBy'] == currentUser['userID']).toList();
      //}

      // Show everything
    } else if (currentUserType == UserType.subjectCoordinator) {
      filteredByUserType = allRequests;
      return;

      // Show based on restrictions given by coordinator (Tutor, etc)
    } else {
      // TODO: Determine which role gets to view what types of request
    }

    //_foundRequests = filteredByUserType;
  }

  // Third filter
  void _filterByAssignment() {

    //List filteredByAssignment = [];

    if (dropdownValue != "All") {
      filteredByAssignment = filteredBySubject.where((request) =>
          request['type'].contains(dropdownValue)).toList();

    }else{
      filteredByAssignment = filteredBySubject.where((request) =>
          request['type'].contains("")).toList();
    }

    _foundRequests = filteredByAssignment;
  }

  // Forth filter // TODO: Make it search for keywords in request as well, not just name search
  void _filterBySearch() {

    List searchResult = [];

    if(searchString.isEmpty) {
      searchResult = filteredByAssignment;

    }else{
      // apply search logic, should change later or not?
      searchResult = filteredByAssignment.where((request) =>
          request['name'].toLowerCase().contains(searchString.toLowerCase())).toList();
    }

    _foundRequests = searchResult;
  }


  @override
  void initState() {
    dropdownValue = filterSelections.first;
    currentUser = widget.currentUser;
    super.initState();

    _filterByUserType();
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

                    controller: nameSearchController,
                    onChanged: (value) {
                      setState(() {
                        searchString = value;
                      });
                    },
                    style: const TextStyle(color: Color(0xFFD4D4D4)),
                    cursorColor: const Color(0xFFD4D4D4),
                    decoration: InputDecoration(
                      labelText: 'Name Search',
                      labelStyle: const TextStyle(color: Color(0xFFD4D4D4)),
                      suffixIcon: const Icon(Icons.search, color: Color(0xFFD4D4D4)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: mainBodyColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // end of search bar

              Divider(
                color: dividerColor,
                thickness: 3,
                height: 1,
              ),

              // Filter Button
              Container(
                //decoration: BoxDecoration(color: filterContainerColor),
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
                          onTap: () {
                            setState(() {
                              // TODO: Retrieve request from database and display, pass in some sort of submission ID
                              widget.openSubmittedRequest(_foundRequests[index]);
                            });
                          },
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
                                      // green tick icon
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.only(right: 7.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Visibility(
                                                visible: _foundRequests[index]['state'] == "approved"? true: false,
                                                child: const Icon(Icons.gpp_good_sharp, color: Colors.green),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

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