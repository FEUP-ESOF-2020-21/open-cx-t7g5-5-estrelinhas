import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageController {
  final storage = FirebaseStorage.instance;

  Future<String> getImgURL(String path) async {
    return await storage.ref(path).getDownloadURL();
  }

  Future<String> uploadFile(String path, File file) async {
    TaskSnapshot task = await storage.ref().child(path).putFile(file);

    return task.ref.getDownloadURL();
  }

}