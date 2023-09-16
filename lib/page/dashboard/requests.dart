/// The requests part of the [Dashboard] page.
///
/// Shows all requests in a list. These are submitted requests for students
/// and received requests for tutors and subject coordinators.

import 'package:flutter/material.dart';
import 'package:specon/backend.dart';

class Requests extends StatefulWidget {
  final String Function() getCurrentSubject;
  final void Function(Map<String, dynamic>) openSubmittedRequest;
  final Map<String, dynamic> currentUser;

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
  final List<String> filterSelections = BackEnd().getAssessments('subjectID');  // TODO: where to call

  final _scrollController = ScrollController();
  final _nameSearchController = TextEditingController();
  
  String _currentSubject = '';
  String _dropdownValue = '';
  String _searchString = '';
  List _allRequests = [];
  List _foundRequests = []; // result showing on screen

  // First filter
  void _filterByAssignment() {
    final List filteredByAssignment;
    if (_dropdownValue != 'All') {
      filteredByAssignment = _allRequests.where((request) {
        return request['type'].contains(_dropdownValue);
      }).toList();
    } else{
      filteredByAssignment = _allRequests.where((request) {
        return request['type'].contains('');
      }).toList();
    }
    _foundRequests = filteredByAssignment;
  }

  // Second filter // TODO: Make it search for keywords in request as well, not just name search
  void _filterBySearch() {
    final List searchResult;
    if(_searchString.isEmpty) {
      searchResult = _foundRequests;
    } else{
      // apply search logic, should change later or not?
      searchResult = _foundRequests.where((request) {
        return request['name'].toLowerCase().contains(
          _searchString.toLowerCase()
        );
      }).toList();
    }
    _foundRequests = searchResult;
  }

  @override
  void initState() {
    super.initState();

    _dropdownValue = filterSelections.first;
    _allRequests = BackEnd().getRequests(_currentSubject, widget.currentUser);
  }

  @override
  Widget build(BuildContext context) {

    // Reset filter stuff after new subject is clicked
    if (widget.getCurrentSubject() != _currentSubject) {
      _currentSubject = widget.getCurrentSubject();
      _dropdownValue = filterSelections.first;
      _nameSearchController.clear();
      _searchString = '';
    }

    return AnimatedBuilder(
      animation: BackEnd(),
      builder: (context, child) {
        _allRequests = BackEnd().getRequests(_currentSubject, widget.currentUser); // TODO: await?
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
                      controller: _nameSearchController,
                      onChanged: (value) {
                        setState(() {
                          _searchString = value;
                        });
                      },
                      style: TextStyle(color: Theme.of(context).colorScheme.surface),
                      cursorColor: Theme.of(context).colorScheme.surface,
                      decoration: InputDecoration(
                        labelText: 'Name Search',
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.surface),
                        suffixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.surface),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            color: Theme.of(context).colorScheme.background,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // end of search bar

                Divider(
                  color: Theme.of(context).colorScheme.surface,
                  thickness: 3,
                  height: 1,
                ),
                // Filter Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  // filter drop down button
                  children: <Widget>[DropdownButton<String>(
                    //dropdownColor: Color(0xFFD4D4D4),
                    iconDisabledColor: Theme.of(context).colorScheme.background,
                    focusColor: Theme.of(context).colorScheme.background,

                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 13),
                    padding: const EdgeInsets.all(1),
                    value: _dropdownValue,
                    items: filterSelections.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged:(value) {
                      setState(() {
                        _dropdownValue = value!;
                      });
                    },
                  ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Divider(
                    color: Theme.of(context).colorScheme.surface,
                    thickness: 3,
                    height: 1,
                  ),
                ),
                // Display requests
                Expanded(
                  child: RawScrollbar(
                    controller: _scrollController,
                    thumbColor: Colors.white38,
                    thumbVisibility: true,
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
                                                visible: _foundRequests[index]['state'] == 'approved'? true : false,
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