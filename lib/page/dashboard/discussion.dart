/// The discussion part of the [Dashboard] page.
///
/// This will display a summary of the filled out [ConsiderationForm] and
/// a section to have a discussion between a student, tutor and subject
/// coordinator.

import 'package:flutter/material.dart';
import 'package:specon/user_type.dart';

import '../../mock_data.dart';
import '../dashboard_page.dart';

import 'package:specon/backend.dart';

class Discussion extends StatefulWidget {
  final Map<String, dynamic> Function() getCurrentRequest;
  final Map<String, dynamic> currentUser;

  const Discussion(
    {
      Key? key,
      required this.getCurrentRequest,
      required this.currentUser
    }
  ) : super(key: key);

  @override
  State<Discussion> createState() => _DiscussionState();
}

class _DiscussionState extends State<Discussion> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();

  void downloadAttachment() {}

  void decline() {}

  @override
  Widget build(BuildContext context) {
    final currentRequest = widget.getCurrentRequest();

    final List discussionThread = allDiscussion.where((discussion) {
      return discussion['discussionID'] == currentRequest['requestID'];
    }).toList();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20, left: 20),
            child: Text(
              widget.getCurrentRequest()['subject'] + ' - Extension',
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.surface, wordSpacing: 5, letterSpacing: 1),
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
                            const Icon(Icons.account_circle_outlined, size: 40.0),
                            const SizedBox(width: 12),
                            // 2nd line should have student num (now temporary submit by), but it is necessary to store in discussion list?
                            Text(
                              '${discussionThread[index]['name']}\n${discussionThread[index]['submittedBy']}',
                              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary),
                            ),
                            // accept decline button
                            if(widget.currentUser['userType'] != UserType.student)
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        BackEnd().accept(discussionThread[index]['discussionID']);
                                      },
                                      child: const Text('Accept'),
                                    ),
                                    TextButton(
                                      onPressed: decline,
                                      child: const Text('Decline'),
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
                            Expanded(
                              child: Text(
                                discussionThread[index]['reason'],
                                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.surface),
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
                          child: Text(
                            'Attachments',
                            style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                    controller: _textController,
                    minLines: 2,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(color: Theme.of(context).colorScheme.surface),
                    cursorColor: Theme.of(context).colorScheme.surface,
                    decoration: InputDecoration(
                      hintText: 'Enter response',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.surface),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: OutlinedButton(
                      onPressed: () {
                        // update database
                        setState(() {
                          allDiscussion.add({
                            'discussionID': currentRequest['requestID'],
                            'submittedBy': 0000,
                            'name': 'tutor name',
                            'subject': currentRequest['subject'],
                            'type': currentRequest['type'],
                            'reason': _textController.value.text,
                          });
                        });
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
