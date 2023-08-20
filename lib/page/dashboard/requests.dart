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
    {"ID": 1, "name": 'Alex', "subject": "COMP30023", "type": "Project 1"},
    {"ID": 2, "name": 'Bob', "subject": "COMP30024", "type": "Project 1"},
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
        //backgroundColor: Color(0xFF333333),
        body: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Column(
            children: [
              // search bar is here
              TextField(
                onChanged: (value) => _searchRequest(value),
                decoration: const InputDecoration(
                  labelText: 'Search', suffixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.black54,
                  hoverColor: Colors.blueGrey,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red,//cant see red idk
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black12,
                    ),
                  ),

                ),
              ),
              Container(
                color: Colors.black38,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[TextButton(
                    child: const Text(
                        'Filter',
                      style: TextStyle(
                        color: Colors.deepOrange,
                      ),
                    ),
                    onPressed: () {/* ... */},
                    ),
                  ],
                ),
              ),

              Expanded(
                // viewing all request
                child: Container(
                  color: Colors.black54,
                  child: ListView.builder(
                    itemCount: _foundRequests.length,
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