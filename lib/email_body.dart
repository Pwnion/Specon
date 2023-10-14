import "package:cloud_firestore/cloud_firestore.dart";


getSummary(final String test) {
  String number_open = '3';
  String summary = '''<body><h2>Summary provided by SPECON</h2>
                      <p>There are $number_open open requests remaining</p>
                      <hr>
                      <h4>open requests in each subject:</h4>
                      <p></p>>
  </body>''';
  return summary;
}

_subjectRequestSummary(List<String> subcorSubjects) async {
  String text = "";
  List<String> subcorSubjects = ["COMP10001"];
  final db = FirebaseFirestore.instance;
  final subjectsRef = db.collection("subjects");

  // loop through subjects
  for(String subject in subcorSubjects){
    var subjectRef = await subjectsRef.where('code', isEqualTo: subject ).get();
    var query = subjectsRef.doc(subjectRef.docs[0].id).collection('requests').where('state', isEqualTo: "Open");
    text += '<p>$subject: {$query.count()} open requests</p>';
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