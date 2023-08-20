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
  // for testing
  List<Map<String, dynamic>> allRequests = [
    {"ID": 1, "name": 'Alex', "subject": "COMP30023"},
    {"ID": 2, "name": 'Bob', "subject": "COMP30024"},
  ];

  List<Map<String, dynamic>> _foundRequests = [];
  @override
  void initState() {
    _foundRequests = allRequests;
    super.initState();
  }
  // function that updates _foundRequests whenever search is used
  void _searchRequest(String searchString){
    List<Map<String, dynamic>> result = [];
    if(searchString.isEmpty) {
      result = allRequests;
    }else{
      // apply search logic, should change later
      result = allRequests.where((request) =>
          request['name'].toLowerCase().contains(searchString.toLowerCase())).toList();
    }
    setState(() {
      _foundRequests = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // search bar is here
              TextField(
                onChanged: (value) => _searchRequest(value),
                decoration: const InputDecoration(
                  labelText: 'Search', suffixIcon: Icon(Icons.search),
                ),

              ),
              const SizedBox(
                height: 20,
              ),

              Expanded(
                // viewing all request
                child: ListView.builder(
                  itemCount: _foundRequests.length,
                    itemBuilder: (context, index) => Card(
                      key: ValueKey(_foundRequests[index]["ID"].toString()),
                      color: Colors.blueGrey,
                      elevation: 2,
                      child: ListTile(
                      leading: Text(_foundRequests[index]["ID"].toString()),
                        title: Text(_foundRequests[index]["name"]),
                        subtitle: Text(_foundRequests[index]["subject"]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}