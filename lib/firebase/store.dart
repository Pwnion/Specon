import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>> getUserByEmail(String email) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
        .collection("users")
        .where("email", isEqualTo: email)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return {}; // Return an empty map if user is not found
    }

    // Assuming "email" is a unique identifier, you can directly use it to get the document
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await firestore.collection("users").doc(querySnapshot.docs[0].id).get();

    if (userDoc.exists) {
      return {
        'email': userDoc.data()!['email'],
        'first_name': userDoc.data()!['first_name'],
        'id': userDoc.data()!['id'],
        'last_name': userDoc.data()!['last_name'],
        'middle_name': userDoc.data()!['middle_name'],
        'role': userDoc.data()!['role'],
        'student_id': userDoc.data()!['student_id'],
        'subjects': userDoc.data()!['subjects'],
      };
    } else {
      return {}; // User not found, return an empty map
    }
  } catch (error) {
    // You can handle the error here if needed
    return {}; // Return an empty map in case of an error
  }
}

Future<Map<String, dynamic>> fetchData() async {
  try {
    // Get a Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Reference to the specific document
    DocumentSnapshot doc = await firestore
        .collection('subjects')
        .doc('comp10001')
        .collection('requests')
        .doc('Fntx6nGWeOXanOmsPk1B')
        .get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Use the data as needed
    return data;
    // Check if the document exists
    // if (doc.exists) {
    //   // Access the data
    // } else {
    //   print('Document does not exist');
    // }
  } catch (e) {
    return {};
  }
}
