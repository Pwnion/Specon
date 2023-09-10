/// The discussion part of the [Dashboard] page.
///
/// This will display a summary of the filled out [ConsiderationForm] and
/// a section to have a discussion between a student, tutor and subject
/// coordinator.

import 'package:flutter/material.dart';

import 'consideration_form.dart';
import '../dashboard_page.dart';

import 'package:specon/backend.dart';

class Discussion extends StatefulWidget {
  final Function getCurrentRequest;
  final Map currentUser;

  const Discussion({
    Key? key,
    required this.getCurrentRequest,
    required this.currentUser
  }
      ) : super(key: key);

  @override
  State<Discussion> createState() => _DiscussionState();
}
Map currentRequest = {'requestID': 1};
class _DiscussionState extends State<Discussion> {
  final _scrollController = ScrollController();
  final _TextController = TextEditingController();
  List allDiscussion = [
    {"discussionID": 1, "submittedBy": 1234, "name": 'Alex', "subject": "COMP30023", "type": "Project 1", "reason": "Pls I beg u"},
    {"discussionID": 2, "submittedBy": 23423, "name": 'Bob', "subject": "COMP30019", "type": "Project 2", "reason": "Plssssssss"},
    {"discussionID": 3, "submittedBy": 34232, "name": 'Aren', "subject": "COMP30022", "type": "Final Exam", "reason": "I dumb"},
    {"discussionID": 4, "submittedBy": 44234, "name": 'Aden', "subject": "COMP30023", "type": "Mid Semester Exam", "reason": "Pls I beg u asd;lfknalksdnfka;sdlkfn;alkdsnfka;sdlkfna;lksdnf;aldkfn;aldknf;alskdnf;alksdnf;alkdsnfa;lkdsfna;l"},
    {"discussionID": 5, "submittedBy": 5432, "name": 'Lo', "subject": "COMP30020", "type": "Project 1", "reason": "Pls I beg u"},
    {"discussionID": 6, "submittedBy": 6423, "name": 'Harry', "subject": "COMP30019", "type": "Project 2", "reason": "Pls I beeeeg u"},
    {"discussionID": 7, "submittedBy": 7432, "name": 'Drey', "subject": "COMP30022", "type": "Project 2", "reason": "Pls I beg u"},
    {"discussionID": 8, "submittedBy": 84234, "name": 'Brian', "subject": "COMP30023", "type": "Final Exam", "reason": "uwu"},
    {"discussionID": 9, "submittedBy": 9234, "name": 'David', "subject": "COMP30019", "type": "Project 1", "reason": "Pls I beg u"},
    {"discussionID": 10, "submittedBy": 10234, "name": 'Po', "subject": "COMP30022", "type": "Project 1", "reason": "Pls uuuu beg u"},
  ];

  List discussionThread = [];

  void downloadAttachment(){}

  void accept(int requestID){
      for(var request in BackEnd().allRequests){
        if(request['requestID'] == requestID){
          setState(() {
            request['state'] = "approved";
          });
        }
      }

  }

  void decline(){}


  @override
  void initState() {
    currentRequest = widget.getCurrentRequest();
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    currentRequest = widget.getCurrentRequest();
    discussionThread = allDiscussion.where((discussion) =>
        discussion['discussionID'] == currentRequest["requestID"]).toList();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20, left: 20),
            child: Text(
              widget.getCurrentRequest()["subject"] + " - Extension",
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 20, color: Color(0xFFD4D4D4), wordSpacing: 5, letterSpacing: 1),
            ),
          ),
          Expanded(
            flex: 5,
              child: ListView.builder(
                      itemCount: discussionThread.length,
                      controller: _scrollController,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Card(
                          surfaceTintColor: const Color(0xFF333333),
                          color: const Color(0xFF333333),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              // display icon, name, and student ID
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const SizedBox(width: 4),
                                    const Icon(Icons.account_circle_outlined, size: 40.0),
                                    const SizedBox(width: 12),
                                    // 2nd line should have student num (now temporary submit by), but it is necessary to store in discussion list?
                                    Text(
                                      discussionThread[index]['name']+"\n"+discussionThread[index]['submittedBy'].toString(),
                                      style: const TextStyle(fontSize: 14, color: Color(0xFFDF6C00)),
                                    ),

                                    // accept decline button
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () => accept(discussionThread[index]["discussionID"]),
                                            child: const Text("Accept"),
                                          ),
                                          TextButton(
                                            onPressed: decline,
                                            child: const Text("Decline"),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // display reason
                              Container(
                                margin: const EdgeInsets.only(top: 10, bottom: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: 55),
                                    // expand is needed for overflow to work
                                    Expanded(
                                      child: Text(
                                        discussionThread[index]['reason'],
                                        style: const TextStyle(fontSize: 16, color: Color(0xFFD4D4D4),),
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // display attach file download button
                              Container(
                                margin: const EdgeInsets.only(top: 10, bottom: 10),
                                child: TextButton(
                                  onPressed: downloadAttachment,
                                  style: TextButton.styleFrom(
                                    alignment: Alignment.centerLeft,
                                  ),
                                  child: const Text(
                                    "Attachments",
                                    style: TextStyle(fontSize: 14, color: Color(0xFFDF6C00)),
                                  ),
                                )
                              ),

                            ],
                          ),
                        ),
                      )
              ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextFormField(
                    controller: _TextController,
                    minLines: 2,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(color: Color(0xFFD4D4D4), ),
                    cursorColor: const Color(0xFFD4D4D4),
                    decoration: const InputDecoration(
                      hintText: "Enter response",
                      hintStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFDF6C00),
                        ),
                      ),
                    ),

                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: OutlinedButton(
                      onPressed: (){
                        // update database
                      },
                      child: const Text("Submit"),
                    ),
                  )

                ],
              ),
            ),
          )

        ],
      ),
    );
  }
}