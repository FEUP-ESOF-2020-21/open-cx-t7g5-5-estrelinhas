import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../model/Conference.dart';

class FirestoreController {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getConferences() {
    Stream<QuerySnapshot> snapshot = firestore.collection("conference").snapshots();

    return snapshot;
  }
}