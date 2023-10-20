/// The requests part of the [Dashboard] page.
///
/// Shows all requests in a list. These are submitted requests for students
/// and received requests for tutors and subject coordinators.
/// Authors: Kuo Wei WU, Zhi Xiang Chan

import 'package:flutter/material.dart';
import 'package:specon/backend.dart';
import 'package:specon/models/request_model.dart';
import 'package:specon/models/subject_model.dart';
import 'package:specon/models/user_model.dart';
import 'package:specon/page/db.dart';
import 'package:specon/user_type.dart';

class Requests extends StatefulWidget {
  final SubjectModel Function() getCurrentSubject;
  final void Function(RequestModel) openSubmittedRequest;
  final UserModel currentUser;
  final String selectedAssessment;
  final UserType role;
  final int counter;
  final RequestModel selectedRequest;

  const Requests(
      {Key? key,
      required this.getCurrentSubject,
      required this.openSubmittedRequest,
      required this.currentUser,
      required this.selectedAssessment,
      required this.role,
      required this.counter,
      required this.selectedRequest})
      : super(key: key);

  @override
  State<Requests> createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {

  final List<String> filterSelectionsState = BackEnd().getRequestStates();
  final _scrollController = ScrollController();
  final _nameSearchController = TextEditingController();

  SubjectModel _currentSubject = SubjectModel.emptySubject;
  String _dropdownValueState = '';
  String _searchString = '';
  bool fetchingRequests = true;
  List<RequestModel> _allRequests = [];
  List<RequestModel> _foundRequests = []; // result showing on screen
  bool assFilterClicked = false;
  bool statusFilterClicked = false;
  int counter = 0;

  static final dataBase = DataBase();

  /// filter request via the filter buttons, listens to any selection changes
  void _applyDropdownFilters() {
    final List<RequestModel> filteredByAssignment;

    if (widget.selectedAssessment != 'All') {
      filteredByAssignment = _allRequests.where((request) {
        return request.assessment.name == widget.selectedAssessment;
      }).toList();
    } else {
      filteredByAssignment = _allRequests;
    }
    _foundRequests = filteredByAssignment;

    final List<RequestModel> filteredByState;

    if (_dropdownValueState != 'All state') {
      filteredByState = _foundRequests.where((request) {
        return request.state == _dropdownValueState;
      }).toList();
    } else {
      filteredByState = _foundRequests;
    }
    _foundRequests = filteredByState;
  }

  // TODO: Make it search for keywords in request as well, not just name search
  /// filter selection from the value entered in the search bar
  void _filterBySearch() {
    final List<RequestModel> searchResult;
    if (_searchString.isEmpty) {
      searchResult = _foundRequests;
    } else {
      // apply search logic, should change later or not?
      searchResult = _foundRequests.where((request) {
        return request.requestedBy
          .toLowerCase()
          .contains(_searchString.toLowerCase());
      }).toList();
    }
    _foundRequests = searchResult;
  }

  /// get all requests from the database
  void fetchRequestsFromDB() {
    dataBase.getRequests(widget.currentUser, _currentSubject).then((requests) {
      if (requests != _allRequests) {
        setState(() {
          _allRequests = requests;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Reset filter stuff after new subject is clicked
    if (widget.getCurrentSubject() != _currentSubject) {
      _currentSubject = widget.getCurrentSubject();
      _dropdownValueState = widget.role == UserType.student ? 'All state' : filterSelectionsState.first;
      _nameSearchController.clear();
      _searchString = '';

      // Fetch requests from database
      fetchingRequests = true;
      dataBase.getRequests(widget.currentUser, _currentSubject) .then((requests) {
        setState(() {
          fetchingRequests = false;
          _allRequests = requests;
        });
      });
    }
    // New Request has been added
    else if (counter != widget.counter){
      // Fetch requests from database
      fetchingRequests = true;
      dataBase.getRequests(widget.currentUser, _currentSubject).then((requests) {
        setState(() {
          fetchingRequests = false;
          _allRequests = requests;
          counter ++;
        });
      });
    }

    // Show requests if not fetching requests from database
    if (!fetchingRequests && _currentSubject.code.isNotEmpty) {
      _applyDropdownFilters();
      _filterBySearch();

      return Scaffold(
        body: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: SizedBox(
                height: 25.0,
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: _nameSearchController,
                  onChanged: (value) {
                    setState(() {
                      _searchString = value;
                    });
                  },
                  style: TextStyle(color: Theme.of(context).colorScheme.surface),
                  cursorColor: Theme.of(context).colorScheme.surface,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Name',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.surface),
                    suffixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.surface
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: Theme.of(context).colorScheme.background,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Divider Line
            Divider(
              color: Theme.of(context).colorScheme.surface,
              thickness: 0.5,
              height: 1,
            ),
            // Filter Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              // filter drop down button
              children: <Widget>[
                // state filter
                //TODO: change this to DropdownMenu
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isDense: true,
                    //itemHeight: 20,
                    //TODO: add kMinInteractiveDimension somewhere
                    iconDisabledColor: Theme.of(context).colorScheme.background,
                    focusColor: Theme.of(context).colorScheme.background,
                    style: TextStyle(
                      color: statusFilterClicked
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.onBackground,
                      fontSize: 12
                    ),
                    padding: const EdgeInsets.all(1),
                    value: _dropdownValueState,
                    items: filterSelectionsState
                      .map<DropdownMenuItem<String>>((String state) {
                      return DropdownMenuItem<String>(
                        value: state,
                        child: Text(state),
                      );
                    }).toList(),
                    onChanged: (state) {
                      statusFilterClicked = true;
                      setState(() {
                        _dropdownValueState = state!;
                      });
                    },
                  ),
                ),
              ],
            ),
            // Divider Line
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Divider(
                color: Theme.of(context).colorScheme.surface,
                thickness: 0.5,
                height: 1,
              ),
            ),
            // Display Requests
            Expanded(
              child: RawScrollbar(
                controller: _scrollController,
                thumbColor: Colors.white38,
                thumbVisibility: true,
                radius: const Radius.circular(5),
                thickness: 0,
                child: ListView.builder(
                  itemCount: _foundRequests.length,
                  controller: _scrollController,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          widget.openSubmittedRequest(_foundRequests[index]);
                        });
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                        ),
                        color: widget.selectedRequest.databasePath == _foundRequests[index].databasePath ? Colors.white70 : Colors.white,
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
                                  Text(_foundRequests[index].requestedBy),
                                  // State Icons
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.only(right: 7.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          // Approved icon
                                          Visibility(
                                            visible: _foundRequests[index].state == 'Approved',
                                            child: const Icon(
                                              Icons.gpp_good_sharp,
                                              color: Colors.green
                                            ),
                                          ),
                                          // Flagged icon
                                          Visibility(
                                            visible:_foundRequests[index].state == 'Flagged',
                                            child: const Icon(
                                              Icons.flag,
                                              color: Colors.orange
                                            ),
                                          ),
                                          // Declined icon
                                          Visibility(
                                            visible: _foundRequests[index].state == 'Declined',
                                            child: const Icon(
                                              Icons.not_interested,
                                              color: Colors.red
                                            ),
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
                                  Text(_foundRequests[index].assessment.name),
                                  const SizedBox(width: 8),
                                  Text(_foundRequests[index].timeSinceSubmission()),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ));
    }
    // No subject is selected
    else if (_currentSubject.code.isEmpty) {
      return Center(
        child: Text('Select a subject',
          style: TextStyle(
            color: Theme.of(context).colorScheme.surface,
            fontSize: 25
          )
        )
      );
    }
    // Fetching requests from database
    else {
      return const SizedBox(
        height: 100.0,
        width: 100.0,
        child: Center(child: CircularProgressIndicator()),
      );
    }
  }
}
