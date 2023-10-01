/// The discussion part of the [Dashboard] page.
///
/// This will display a summary of the filled out [ConsiderationForm] and
/// a section to have a discussion between a student, tutor and subject
/// coordinator.
/// Author: Kuo Wei Wu

import 'package:firebase_storage/firebase_storage.dart';
import 'package:specon/models/request_model.dart';
import 'package:specon/page/db.dart';
import 'package:specon/user_type.dart';

import '../dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:specon/models/user_model.dart';
import 'package:specon/backend.dart';
import 'package:specon/storage.dart';

class Discussion extends StatefulWidget {
  final RequestModel currentRequest;
  final UserModel currentUser;

  const Discussion(
    {Key? key,
    required this.currentRequest,
    required this.currentUser
    }
  ): super(key: key);

  @override
  State<Discussion> createState() => _DiscussionState();
}

class _DiscussionState extends State<Discussion> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  static final _db = DataBase();
  UploadTask? _uploadTask;
  List discussionThread = [];
  bool fetchingFromDB = true;

  /// download documents from the cloud storage related to the selected request
  //void _downloadAttachment() {}

  /// display upload documents status, should be in submit request form later
  void _displayUploadState(){
    _uploadTask!.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          print("Upload is $progress% complete.");
          break;
        case TaskState.paused:
          print("Upload is paused.");
          break;
        case TaskState.canceled:
          print("Upload was canceled");
          break;
        case TaskState.error:
        // Handle unsuccessful uploads
          break;
        case TaskState.success:
        // Handle successful uploads on complete
        // ...
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    // Fetch discussions from the database
    _db.getDiscussionThreads(widget.currentRequest).then((discussionThread) {
      setState(() {
        this.discussionThread = discussionThread;
        fetchingFromDB = false;
      });
    });

    if (!fetchingFromDB) {
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title of the discussion thread
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20, left: 20),
              child: Text(
                discussionThread[0]['subject'] + ' - ' + discussionThread[0]['assessment'],
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.surface,
                  wordSpacing: 5,
                  letterSpacing: 1
                ),
              ),
            ),
            // All discussion text are put in a listView.builder as a card
            Expanded(
              flex: 5,
              child: ListView.builder(
                itemCount: discussionThread.length,
                controller: _scrollController,
                itemBuilder: (context, index) =>
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Card(
                        surfaceTintColor: Theme.of(context).colorScheme.background,
                        color: Theme.of(context).colorScheme.background,
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
                                  const Icon(Icons.account_circle_outlined,
                                      size: 40.0),
                                  const SizedBox(width: 12),
                                  // 2nd line should have student num (now temporary submit by), but it is necessary to store in discussion list?
                                  Text(
                                    '${discussionThread[index]['submittedBy']}\n${discussionThread[index]['submittedByUserID']}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color:Theme.of(context).colorScheme .secondary),
                                  ),
                                  // accept decline flag button
                                  if(widget.currentUser.role !=
                                      UserType.student &&
                                      discussionThread[index]["type"] == "request")
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              // BackEnd().accept(discussionThread[index]['discussionID']); TODO
                                            },
                                            child: const Text('Accept'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // BackEnd().decline(discussionThread[index]['discussionID']); TODO
                                            },
                                            child: const Text('Decline'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // BackEnd().flag(discussionThread[index]['discussionID']); TODO
                                            },
                                            child: const Text('Flag'),
                                          )
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // display reason
                            Container(
                              margin: const EdgeInsets.only(
                                  top: 10, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(width: 55),
                                  Expanded(
                                    child: Text(
                                      discussionThread[index]['reason'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                        Theme.of(context).colorScheme.surface
                                      ),
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // display attach file download button
                            if(discussionThread[index]['type'] == 'request')
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 10, bottom: 10),
                                child: TextButton(
                                  onPressed: () {},
                                  // onPressed: ()=> downloadFiles(currentRequest['requestID']),  //downloadAttachment, TODO
                                  style: TextButton.styleFrom(
                                    alignment: Alignment.centerLeft,
                                  ),
                                  child: Text(
                                    'Attachments',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).colorScheme.secondary
                                    ),
                                  ),
                                ),
                              ),
                            // temporary upload button, upload button should be on application form
                            Container(
                              margin: const EdgeInsets.only(
                                  top: 10, bottom: 10),
                              child: TextButton(
                                onPressed: () {
                                  // _uploadTask = uploadFile(currentRequest['requestID']); TODO
                                  _displayUploadState();
                                }, //downloadAttachment,
                                style: TextButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                ),
                                child: Text(
                                  'upload',
                                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary),
                                ),
                              ),
                            ),
                            // temporary select file button
                            Container(
                              margin: const EdgeInsets.only(
                                  top: 10, bottom: 10),
                              child: TextButton(
                                onPressed: selectFile, //downloadAttachment,
                                style: TextButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                ),
                                child: Text(
                                  'select file',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Theme
                                          .of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ),
            ),
            // response box and a submit button that updates the discussion thread data
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.primary)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(5),
                      child: TextFormField(
                        controller: _textController,
                        minLines: 2,
                        maxLines: 2,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(color: Theme.of(context).colorScheme.surface),
                        cursorColor: Theme.of(context).colorScheme.surface,
                        decoration: InputDecoration(
                          hintText: 'Enter response',
                          hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.surface, fontSize: 13, letterSpacing: 2
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // button that submit the response
                    Container(
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, top: 20),
                      child: OutlinedButton(
                        onPressed: () async {
                          // only update database if field has any word
                          if(_textController.value.text != ""){
                              await _db.addNewDiscussion(widget.currentRequest,
                                {
                                  'assessment': discussionThread[0]['assessment'],
                                  'reason': _textController.value.text,
                                  'subject': discussionThread[0]['subject'],
                                  'submittedBy': widget.currentUser.firstName,
                                  'submittedByUserID': widget.currentUser.id,
                                  'type': widget.currentUser.role == UserType.student? 'request': 'respond',
                              });
                          }
                          _textController.clear();
                        },
                        child: Text('Submit', style: TextStyle(color: Theme.of(context).colorScheme.secondary)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }
}
