/// This returns the body of the email, both state change for students
/// and summary email for subject coordinators
/// Main author: Kuo Wei Wu
import "package:cloud_firestore/cloud_firestore.dart";

getSummary(final String test) async{
  String number_open = await _subjectRequestSummary(['COMP10001'], true);
  String individualSubjectSummary = await _subjectRequestSummary(['COMP10001'], false);
  String summary = '''<body><h2>Summary provided by SPECON</h2>
                      <p>There are $number_open open requests remaining</p>
                      <hr>
                      <h4>open requests in each subject:</h4>
                      
  </body>''';
  return summary;
}

Future<String> _subjectRequestSummary(List<String> subcorSubjects, bool getTotalNumber) async {
  String text = "";
  List<String> subcorSubjects = ["COMP10001"];
  num count = 0;
  final db = FirebaseFirestore.instance;
  final subjectsRef = db.collection("subjects");

  // loop through subjects
  for(String subject in subcorSubjects){
    var subjectRef = await subjectsRef.where('code', isEqualTo: subject ).get();
    var query = await subjectsRef.doc(subjectRef.docs[0].id).collection('requests').where('state', isEqualTo: "Open").get();
    text += '<p>$subject: {$query.docs.length} open requests</p>';
    count += query.docs.length;
  }

  if(getTotalNumber){
    return count.toString();
  }
  return text;
}

requestReplyMessage(final String request) {
  String name = 'asdf';
  String status = "approved";
  String subject = "COMP10001";
  String assessment = "Project1";
  String reason = "uwu";
  String additional = "owo";
  String summary = '''<body><h2>Your request status has been updated</h2>
                      <p>Dear $name <br>
                      Your request's status has now been change to</p>
                      <h3>$status</h3>
                      <hr>
                      <h4>Your request information:</h4>
                      <p>Subject: $subject<br>
                      Assessment: $assessment<br><br>
                      Reason: $reason<br></p>
                      <p>Best regards<br>
                      SPECON</p>
  </body>''';
  return summary;
}