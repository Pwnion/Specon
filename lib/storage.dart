/// Functionality relate to cloud storage
///
/// This will manage every functionality related to cloud
/// storage, including upload, download...etc
/// Author: Kuo Wei Wu

import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

final _storage = FirebaseStorage.instance;
final _storageRef = _storage.ref();
final _documentsRef = _storageRef.child("documents");
PlatformFile? pickedFile;

/// Make user's computer pop up a file window to select file
Future<bool> selectFile() async{
  final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
  if(result == null){
    return false;
  }
  pickedFile = result.files.first;
  print(pickedFile!.name);
  return true;
}

/// upload the selected file to cloud storage in the path 'documents/{requestID}'
UploadTask uploadFile(int requestID) {
  final ref = _documentsRef.child("${requestID.toString()}/${pickedFile!.name}");
  final fileBytes = pickedFile!.bytes; // on web app this is necessary
  return ref.putData(fileBytes!);
}

/// download all file that is in 'documents/{requestID}'
void downloadFiles (int requestID) async{
  final downloadList = await _documentsRef.child(requestID.toString()).listAll();

  for (var item in downloadList.items) {
    try {
      const oneHundredMegabyte = 100 * 1024 * 1024;
      final Uint8List? data = await item.getData(oneHundredMegabyte);
    } on FirebaseException catch (e) {
      print("Failed with error '${e.code}': ${e.message}");
    }
  }
}
