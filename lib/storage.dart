import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

final storage = FirebaseStorage.instance;
final storageRef = FirebaseStorage.instance.ref();
final documentsRef = storageRef.child("documents");
PlatformFile? pickedFile;


Future<bool> selectFile() async{
  final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
  if(result == null){
    return false;
  }
  pickedFile = result.files.first;
  print(pickedFile!.name);
  return true;
}

UploadTask uploadFile(int requestID) {
  final ref = documentsRef.child("${requestID.toString()}/${pickedFile!.name}");
  final fileBytes = pickedFile!.bytes; // on web app this is necessary
  return ref.putData(fileBytes!);
}

void downloadFiles (int requestID) async{
  final downloadList = await documentsRef.child(requestID.toString()).listAll();

  for (var item in downloadList.items) {
    try {
      const oneHundredMegabyte = 100 * 1024 * 1024;
      final Uint8List? data = await item.getData(oneHundredMegabyte);
    } on FirebaseException catch (e) {
      print("Failed with error '${e.code}': ${e.message}");
    }
  }
}
