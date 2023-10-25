/// Functionality relate to cloud storage
///
/// This will manage every functionality related to cloud
/// storage, including upload, download...etc
/// Author: Kuo Wei Wu

import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:requests/requests.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:html' as html;


final _storage = FirebaseStorage.instance;
final _storageRef = _storage.ref();
final _documentsRef = _storageRef.child("documents");
//PlatformFile? pickedFile;

/// Make user's computer pop up a file window to select file
Future<FilePickerResult?> selectFile() async{
  final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'txt'], // need change later
      allowMultiple: true
  );
  if(result == null){
    return null;
  }
  return result;
}

/// Make user's computer pop up a file window to select one single file
Future<FilePickerResult?> selectSingleFile() async{
  final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'txt'],
      allowMultiple: false
  );
  if(result == null){
    return null;
  }
  return result;
}

/// get aap file's name using folder name (folder should have only 1 file)
Future<String> getAapFileName(String dataPath) async {
  try{
    var temp = await _documentsRef.child(dataPath).listAll();
    return temp.items.first.name;
  } on FirebaseException catch (e2) {
    print("Failed with error '${e2.code}': ${e2.message}");
    return "no AAP";
  }
}

void _downloadFile(String url) {
  html.AnchorElement anchorElement =  new html.AnchorElement(href: url);
  anchorElement.download = url;
  anchorElement.click();
}

void clearFolder(String dataPath) async{
  try{
    var folder = await _documentsRef.child(dataPath).listAll();
    for (var item in folder.items) {
      try {
        item.delete();
      } on FirebaseException catch (e) {
        print("Failed with error '${e.code}': ${e.message}");
      }
    }

  } on FirebaseException catch (e2) {
    print("Failed with error '${e2.code}': ${e2.message}");
  }

}

/// upload the selected file to cloud storage in the path 'documents/{requestID/userID}'
UploadTask? uploadFile(String dataPath, FilePickerResult filePickerResult) {
  Reference? ref;
  Uint8List? fileBytes;
  UploadTask? uploadTask;
  for(PlatformFile file in filePickerResult.files){
    ref = _documentsRef.child("$dataPath/${file!.name}");
    fileBytes = file!.bytes; // on web app this is necessary
    uploadTask = ref.putData(fileBytes!);
  }
  return uploadTask;
}

/// download all file that is in 'documents/{requestID} to memory'
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

/// download all file that is in 'documents/{requestID} to Disc using URL'
void downloadFilesToDisc (String dataPath, String aapPath) async{
  final downloadList = await _documentsRef.child(dataPath).listAll();

  // if user has aap, download their aap as well
  try{
    final aapList = await _documentsRef.child(aapPath).listAll();
    for (var item in aapList.items) {
      try {
        //File downloadPath = File("$dir/${item.name}");
        //Uri url = Uri.parse(await item.getDownloadURL());

        // if (!await launchUrl(url)) {
        //   throw Exception('Could not launch $url');
        // }

        String url = await item.getDownloadURL();
        //Requests.get(url, verify: false);

        // Uint8List? data = await item.getData();
        // await FileSaver.instance.saveFile(name: item.name, bytes: data);

        _downloadFile(url);

      } on FirebaseException catch (e2) {
        print("Failed with error '${e2.code}': ${e2.message}");
      }
    }
  }on FirebaseException catch(e1){
    print("Failed with error '${e1.code}': ${e1.message}");
  }

  // download everything in the attachments folder (exclude aap)
  for (var item in downloadList.items) {
    try {
      //File downloadPath = File("$dir/${item.name}");
      // Uri url = Uri.parse(await item.getDownloadURL());
      //
      // if (!await launchUrl(url)) {
      //   throw Exception('Could not launch $url');
      // }
      String url = await item.getDownloadURL();
      //Requests.get(url, verify: false);

      // Uint8List? data = await item.getData();
      // await FileSaver.instance.saveFile(name: item.name, bytes: data);
      // launchUrl(url)

      _downloadFile(url);

    } on FirebaseException catch (e) {
      print("Failed with error '${e.code}': ${e.message}");
    }
  }
}
