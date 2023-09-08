/// The requests part of the [Dashboard] page.
///
/// Shows all requests in a list. These are submitted requests for students
/// and received requests for tutors and subject coordinators.

import 'package:flutter/material.dart';
import 'package:specon/backend.dart';

class Requests extends StatefulWidget {

  final Function getCurrentSubject;
  final Function openSubmittedRequest;
  final Map currentUser; //whats this for

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

  final onPrimary = const Color(0xFFDF6C00);
  final topBarColor = const Color(0xFF385F71);
  final filterContainerColor = Colors.white10;
  final dividerColor = Colors.white30;
  final mainBodyColor = const Color(0xFF333333);
  final requestColor = const Color(0xFFD4D4D4);
  final _scrollController = ScrollController();
  final nameSearchController = TextEditingController();
  Map currentUser = {}; // TODO: Get from dashboard
  String currentSubject = ''; // TODO: Get from dashboard
  String dropdownValue = '';
  String searchString = '';
  List allRequests = [];
  List _foundRequests = []; // result showing on screen

  // First filter
  void _filterByAssignment() {

    List filteredByAssignment = [];

    if (dropdownValue != "All") {
      filteredByAssignment = allRequests.where((request) =>
          request['type'].contains(dropdownValue)).toList();

    }else{
      filteredByAssignment = allRequests.where((request) =>
          request['type'].contains("")).toList();
    }

    _foundRequests = filteredByAssignment;
  }

  // Second filter // TODO: Make it search for keywords in request as well, not just name search
  void _filterBySearch() {

    List searchResult = [];

    if(searchString.isEmpty) {
      searchResult = _foundRequests;

    }else{
      // apply search logic, should change later or not?
      searchResult = _foundRequests.where((request) =>
          request['name'].toLowerCase().contains(searchString.toLowerCase())).toList();
    }

    _foundRequests = searchResult;
  }

  // Search for new request or update request status every 1 second
  Stream<List> getRequests() async* {

    while(true) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          allRequests = BackEnd().getRequests(currentSubject, currentUser); // TODO: await?
        });
      }
    }
  }

  @override
  void initState() {
    dropdownValue = filterSelections.first;
    currentUser = widget.currentUser;
    allRequests = BackEnd().getRequests(currentSubject, currentUser);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if (widget.getCurrentSubject() != currentSubject) {
      currentSubject = widget.getCurrentSubject();
      dropdownValue = filterSelections.first;
      nameSearchController.clear();
      searchString = '';
    }

    _filterByAssignment();
    _filterBySearch();

    return StreamBuilder<Object>(
      stream: getRequests(),
      builder: (context, snapshot) {
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
    );
  }
}