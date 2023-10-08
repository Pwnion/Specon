/// Functionality relate to cloud storage
///
/// This will manage every functionality related to cloud
/// storage, including upload, download...etc
/// Author: Kuo Wei Wu

import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';


final _storage = FirebaseStorage.instance;
final _storageRef = _storage.ref();
final _documentsRef = _storageRef.child("documents");
PlatformFile? pickedFile;

/// Make user's computer pop up a file window to select file
Future<String> selectFile() async{
  final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
  if(result == null){
    return "file not selected";
  }
  pickedFile = result.files.first;
  print(pickedFile!.name);
  return pickedFile!.name;
}

/// upload the selected file to cloud storage in the path 'documents/{requestID}'
UploadTask uploadFile(String dataPath) {
  print(dataPath);
  final ref = _documentsRef.child("$dataPath/${pickedFile!.name}");
  final fileBytes = pickedFile!.bytes; // on web app this is necessary
  return ref.putData(fileBytes!);
}

/// download all file that is in 'documents/{requestID}'
void downloadFilesToMemory (String dataPath) async{
  final downloadList = await _documentsRef.child(dataPath).listAll();

  for (var item in downloadList.items) {
    try {
      const oneHundredMegabyte = 100 * 1024 * 1024;
      final Uint8List? data = await item.getData(oneHundredMegabyte);
    } on FirebaseException catch (e) {
      print("Failed with error '${e.code}': ${e.message}");
    }
  }
}

void downloadFilesToDisc (String dataPath) async{
  final downloadList = await _documentsRef.child(dataPath).listAll();
  //final dir = await FilePicker.platform.getDirectoryPath();
  //File file;
  for (var item in downloadList.items) {
    try {
      //File downloadPath = File("$dir/${item.name}");
      Uri url = Uri.parse(await item.getDownloadURL());

      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }


      // final downloadTask = item.writeToFile(downloadPath);
      // downloadTask.snapshotEvents.listen((taskSnapshot) {
      //   switch (taskSnapshot.state) {
      //     case TaskState.running:
      //     // TODO: Handle this case.
      //       break;
      //     case TaskState.paused:
      //     // TODO: Handle this case.
      //       break;
      //     case TaskState.success:
      //     // TODO: Handle this case.
      //       break;
      //     case TaskState.canceled:
      //     // TODO: Handle this case.
      //       break;
      //     case TaskState.error:
      //     // TODO: Handle this case.
      //       break;
      //   }
      // });
    } on FirebaseException catch (e) {
      print("Failed with error '${e.code}': ${e.message}");
    }
  }
}
