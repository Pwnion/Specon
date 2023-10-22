/// The discussion part of the [Dashboard] page.
///
/// This will display a summary of the filled out [ConsiderationForm] and
/// a section to have a discussion between a student, tutor and subject
/// coordinator.
/// Author: Kuo Wei Wu

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:specon/models/request_model.dart';
import 'package:specon/db.dart';
import 'package:specon/user_type.dart';

import '../dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:specon/models/user_model.dart';
import 'package:specon/storage.dart';

class Discussion extends StatefulWidget {
  final RequestModel currentRequest;
  final UserModel currentUser;
  final String role;
  final String subjectCode;
  final void Function() incrementCounter;
  final void Function() closeSubmittedRequest;

  const Discussion(
      {Key? key,
      required this.currentRequest,
      required this.currentUser,
      required this.role,
      required this.subjectCode,
      required this.incrementCounter,
      required this.closeSubmittedRequest})
      : super(key: key);

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
  bool _openResponse = false;
  bool _showClearButton = false;
  FilePickerResult? _selectedFiles;
  String _displayFileNames = "";
  String? aapPath;

  void _setDisplayFileName(String name) {
    setState(() {
      _displayFileNames = name;
    });
  }

  void _setShowClearButton(bool value) {
    setState(() {
      _showClearButton = value;
    });
  }

  /// display upload documents status, should be in submit request form later
  void _displayUploadState() {
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

  void setOpenResponse(bool setTo) {
    setState(() {
      _openResponse = setTo;
    });
  }

  /// creates a request summary message at the top of the thread
  void createFormInfoThread() {
    RequestModel cr = widget.currentRequest;
    Map<String, String> info = {
      "assessment": "",
      "type": "form",
      "subject": "",
      "submittedBy": "Request Summary",
      "submittedByUserID": "This is auto-generated by SPECON",
      "text": "Request by ${cr.requestedBy}\n"
          "Student ID: ${cr.requestedByStudentID}\n"
          "Assessment: ${cr.assessment.name}\n"
          "Request Type: ${cr.requestType}\n"
          "Assessed by: ${cr.assessedBy}\n"
          "State of Request: ${cr.state}\n\n"
          "Reason: ${cr.reason}\n"
          "Additional Info: ${cr.additionalInfo}"
    };
    discussionThread.insert(0, info);
  }

  /// string creation for submitted file for discussion response
  String _selectedFileToString() {
    if (_displayFileNames == "") {
      return "";
    }
    return "\n\nSubmitted file:\n$_displayFileNames";
  }

  /// updates the state attribute of the discussion locally
  void updateLocalRequestState(String state) {
    setState(() {
      widget.currentRequest.state = state;
    });
  }

  /// resets selected file and the displaying file name
  void _clearFileVariables() {
    setState(() {
      _selectedFiles = null;
      _displayFileNames = "";
    });
  }

  /// determine whether the reply button can be show
  bool _showReplyButtonCheck() {
    if (UserTypeUtils.convertString(widget.role) == UserType.student) {
      // check if there's any respond in thread, if there is then can show button
      for (var thread in discussionThread) {
        if (thread['type'] == "respond") {
          return !_openResponse;
        }
      }
      // not valid to show reply button
      return false;
    }
    return !_openResponse;
  }

  void _initializeThread() {
    _db.getDiscussionThreads(widget.currentRequest).then((discussionThread) {
      if (mounted) {
        setState(() {
          this.discussionThread = discussionThread;
          fetchingFromDB = false;
        });
      }
      // add form info to first thread, put it here to solve UI glitch
      createFormInfoThread();
    });
  }

  Future<bool?> deleteConfirmationPopUp() {
    return showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (_) => StatefulBuilder(
              builder: (_, setState) => AlertDialog(
                title: Text("Are you sure you want to delete this request?",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.surface)),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Yes'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('No'),
                  ),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    DocumentReference requestRef =
        FirebaseFirestore.instance.doc(widget.currentRequest.databasePath);
    aapPath = widget.currentUser.aapPath;

    // Fetch discussions from the database
    //discussionThread = [];
    _initializeThread();

    if (!fetchingFromDB) {
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title of the discussion thread
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 0.0, left: 20),
              child: Text(
                "${widget.subjectCode} - ${widget.currentRequest.assessment.name}",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.surface,
                    wordSpacing: 5,
                    letterSpacing: 1),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // display name and ID
                  Text(
                    '   ${widget.currentRequest.requestedBy}  ${widget.currentRequest.requestedByStudentID}',
                    style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 3,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  // accept decline flag button, only show to non student
                  if (UserTypeUtils.convertString(widget.role) !=
                      UserType.student)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              acceptRequest(widget.currentRequest);
                              updateLocalRequestState("Approved");
                              widget.incrementCounter();
                            },
                            child: const Text('Accept'),
                          ),
                          TextButton(
                            onPressed: () {
                              declineRequest(widget.currentRequest);
                              updateLocalRequestState("Declined");
                              widget.incrementCounter();
                            },
                            child: const Text('Decline'),
                          ),
                          TextButton(
                            onPressed: () {
                              flagRequest(widget.currentRequest);
                              updateLocalRequestState("Flagged");
                              widget.incrementCounter();
                            },
                            child: const Text('Flag'),
                          ),
                        ],
                      ),
                    ),

                  // Delete button for student and request is still open
                  if (UserTypeUtils.convertString(widget.role) ==
                          UserType.student &&
                      widget.currentRequest.state == 'Open')
                    TextButton(
                      onPressed: () {
                        deleteConfirmationPopUp().then((value) {
                          if (value == true) {
                            _db.deleteOpenRequest(widget.currentRequest);
                            widget.closeSubmittedRequest();
                            widget.incrementCounter();
                          }
                        });
                      },
                      child: const Text('Delete'),
                    ),
                ],
              ),
            ),

            // All discussion text are put in a listView.builder as a card
            Expanded(
              flex: 12,
              child: ListView.builder(
                itemCount: discussionThread.length,
                controller: _scrollController,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Card(
                    shape: BeveledRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.0,
                      ),
                    ),
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                            ],
                          ),
                        ),
                        // display text
                        Container(
                          margin: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(width: 55),
                              Expanded(
                                child: Text(
                                  discussionThread[index]['text'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // display attach file download button
                        if (discussionThread[index]['type'] == 'form')
                          Container(
                            margin: const EdgeInsets.only(top: 10, bottom: 10),
                            child: TextButton(
                              onPressed: () => downloadFilesToDisc(
                                  requestRef.id,
                                  aapPath), //downloadAttachment, TODO
                              style: TextButton.styleFrom(
                                alignment: Alignment.centerLeft,
                              ),
                              child: Text(
                                'Attachments',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
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

            Visibility(
              visible: _showReplyButtonCheck(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                  onPressed: () => setOpenResponse(true),
                  child: Text('Reply',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.surface)),
                ),
              ),
            ),

            // response box and a submit button that updates the discussion thread data
            Visibility(
              visible: _openResponse,
              child: Expanded(
                flex: 5,
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.primary)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(5),
                              child: TextFormField(
                                controller: _textController,
                                minLines: 2,
                                maxLines: 3,
                                keyboardType: TextInputType.multiline,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.surface),
                                cursorColor:
                                    Theme.of(context).colorScheme.surface,
                                decoration: InputDecoration(
                                  hintText: 'Enter response',
                                  hintStyle: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      fontSize: 13,
                                      letterSpacing: 2),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // select file, show file name and clear button for student
                            if (UserTypeUtils.convertString(widget.role) ==
                                UserType.student)
                              Expanded(
                                child: Row(
                                  children: [
                                    // select file button
                                    TextButton(
                                      onPressed: () async {
                                        _selectedFiles = await selectFile();
                                        _setDisplayFileName(
                                            _selectedFiles!.names.join("\n"));
                                        _setShowClearButton(true);
                                      }, //downloadAttachment,
                                      style: TextButton.styleFrom(
                                        alignment: Alignment.centerLeft,
                                      ),
                                      child: Text(
                                        'select file',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                      ),
                                    ),

                                    // display selected file names
                                    Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            _displayFileNames,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // clear file selection button
                                    Visibility(
                                      visible: _showClearButton,
                                      child: TextButton(
                                        onPressed: () {
                                          _clearFileVariables();
                                          _setShowClearButton(false);
                                        }, //downloadAttachment,
                                        style: TextButton.styleFrom(
                                          alignment: Alignment.centerLeft,
                                        ),
                                        child: Text(
                                          'Clear',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      // close window button and submit button
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            // button that closes the response box
                            TextButton(
                                child: Text('Close',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface)),
                                onPressed: () => setOpenResponse(false)),
                            // button that submit the response, also submit selected files
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: ButtonTheme(
                                      height: 20,
                                      minWidth: 30,
                                      child: TextButton(
                                        style: ButtonStyle(
                                            shape: MaterialStatePropertyAll(
                                                RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary)))),
                                        onPressed: () async {
                                          // only update database if field has any word
                                          if (_textController.value.text !=
                                              "") {
                                            await _db.addNewDiscussion(
                                                widget.currentRequest, {
//                                                   'assessment': widget.currentRequest.assessment,
//                                                   'reason': "${_textController.value.text}\nSubmitted file:\n$_displayFileNames",
//                                                   'subject': discussionThread[1]['subject'],
//                                                   'submittedBy': widget.currentUser.name,
                                              //'assessment': widget.currentRequest.assessment,
                                              'text':
                                                  "${_textController.value.text}${_selectedFileToString()}",
                                              //'subject': discussionThread[1]['subject'],
                                              'submittedBy':
                                                  widget.currentUser.name,
                                              'submittedByUserID':
                                                  UserTypeUtils.convertString(
                                                              widget.role) ==
                                                          UserType.student
                                                      ? widget.currentUser
                                                          .studentID!
                                                      : widget.currentUser.id,
                                              'type':
                                                  UserTypeUtils.convertString(
                                                              widget.role) ==
                                                          UserType.student
                                                      ? 'request'
                                                      : 'respond',
                                            });
                                          }
                                          // upload document if has selected file
                                          if (_selectedFiles != null) {
                                            _uploadTask = uploadFile(
                                                requestRef.id, _selectedFiles!);
                                            _displayUploadState();
                                          }
                                          // clear all variables
                                          _textController.clear();
                                          _clearFileVariables();
                                        },
                                        child: Text('Submit',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
