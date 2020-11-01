import 'package:firebase_storage/firebase_storage.dart';

class StorageController {
  final storage = FirebaseStorage.instance;

  Future<String> getImgURL(String path) async {
    return await storage.ref(path).getDownloadURL();
  }
}