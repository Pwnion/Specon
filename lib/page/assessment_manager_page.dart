/// Class responsible for managing assessments for a subject.
///
/// This widget allows users to add, edit, and reorder assessments for a subject.
///
/// Author: Drey Nguyen
import 'package:flutter/material.dart';
import '../models/request_type.dart';
import 'package:specon/db.dart';

import '../widgets/request_item.dart';
import 'package:specon/models/subject_model.dart';

class AssessmentManager extends StatefulWidget {
  final SubjectModel subject;
  final Function refreshFn;
  final Function? onboardRefreshFn;

  /// Constructor for AsmManager widget.
  ///
  /// [subject] is the subject for which assessments are managed.
  /// [refreshFn] is a function to refresh the UI after updates.
  const AssessmentManager(
      {Key? key,
      required this.subject,
      required this.refreshFn,
      this.onboardRefreshFn})
      : super(key: key);

  @override
  State<AssessmentManager> createState() => _AssessmentManagerState();
}

class _AssessmentManagerState extends State<AssessmentManager> {
  /// Lists to manage request types.
  ///
  /// [_requestTypesList] is for display purposes.
  /// [_foundRequestType] is used to update the SubjectModel.
  // final List<RequestType> _requestTypesList = RequestType.importTypes();
  final List<RequestType> _foundRequestType = [];

  final List<RequestType> _addToDb = [];
  final List<String> _deleteToDb = [];
  final Map<String, String> _updateToDb = {};

  static final _db = DataBase();

  @override
  void initState() {
    super.initState();
    _foundRequestType.addAll(widget.subject.assessments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 15,
            ),
            // Back button and subject code section.
            child: Row(
              children: [
                BackButton(
                  color: Theme.of(context).colorScheme.surface,
                  onPressed: () {
                    // Navigate back to the previous screen.
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Adding assessments to ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: '"${widget.subject.code}"',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .primary, // Change the color here
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    List<RequestType> importedTypes =
                        await _db.importFromCanvas(widget.subject.code);

                    if (importedTypes.isEmpty) {
                      // Show error message if no assessments on canvas.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error: No assessments to found on Canvas.',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {}
                    setState(() {
                      _foundRequestType.addAll(importedTypes);
                      _addToDb.addAll(importedTypes);
                    });
                  },
                  child: const Text('Import from Canvas'),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                ElevatedButton(
                  onPressed: () => _showAddNewItemDialog(),
                  child: const Text('Add new'),
                ),
              ],
            ),
          ),
          Expanded(
            // Container displaying assessment lists.
            child: Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _foundRequestType.isEmpty
                  ? Center(
                      child: Text(
                        'Nothing to show here',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = _foundRequestType.removeAt(oldIndex);
                          _foundRequestType.insert(newIndex, item);
                        });
                      },
                      children: _foundRequestType.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;

                        return RequestTypeItem(
                          // Use RequestTypeItem widget here.
                          key: ValueKey(index),
                          requestType: item,
                          onDeleteItem: _deleteAssessment,
                          onUpdateName: updateRequestTypeName, // Add this line.
                        );
                      }).toList(),
                    ),
            ),
          ),
          // Import or update button section.
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: ElevatedButton(
              onPressed: () {
                if (_foundRequestType.isEmpty) {
                  // Show error message if no assessments to import.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error: No assessments to import.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  if (widget.subject.code != "") {
                    setState(() {
                      widget.subject.assessments.clear();
                      widget.subject.assessments
                          .addAll(List.from(_foundRequestType));
                    });

                    _pushToDB();
                  }
                  widget.refreshFn(() {});

                  // if check
                  if (widget.onboardRefreshFn != null) {
                    widget.onboardRefreshFn!();
                  }

                  Navigator.pop(context);
                }
              },
              child: Text(
                widget.subject.assessments.isEmpty ? 'Import' : 'Update',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// helper function that push changes of assessment to DB
  Future<void> _pushToDB() async {
    // add
    for (final assessment in _addToDb) {
      await _db.createAssessment(widget.subject.databasePath, assessment);
    }

    // update
    _updateToDb.forEach((subjectPath, newName) async {
      await _db.updateAssessmentName(subjectPath, newName);
    });

    // delete
    for (final assessmentPath in _deleteToDb) {
      await _db.deleteAssessment(widget.subject.databasePath, assessmentPath);
    }
  }

  /// Helper function that updates the request name in real-time after an update.
  void updateRequestTypeName(String path, String newName) {
    setState(() {
      // Find the RequestType by ID and update its name.
      _foundRequestType.firstWhere((type) => type.databasePath == path).name =
          newName;
    });
    _updateToDb[path] = newName;
  }

  /// helper function asking to add new individual assessment
  Future<void> _showAddNewItemDialog() async {
    String newItemName = '';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add New Item',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (value) {
                      newItemName = value;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter a new assessment',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (newItemName.isNotEmpty) {
                            _addAssessment(newItemName);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// helper function delete assessment
  void _deleteAssessment(String id) {
    setState(() {
      _foundRequestType.removeWhere((item) => item.id == id);
    });
    _deleteToDb.add(id);
  }

  /// helper function add assessment
  void _addAssessment(String name) {
    final assessment = RequestType(id: '-69', name: name, databasePath: '');
    setState(() {
      _foundRequestType.add(assessment);
    });

    // add to temp stack
    _addToDb.add(assessment);
  }
}
