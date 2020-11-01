import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../model/Conference.dart';

class FirestoreController {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getConferences() {
    Stream<QuerySnapshot> snapshot = firestore.collection("conference").snapshots();

    return snapshot;
  }

  Future<Conference> getConferenceByID(String id) async {
    Conference conf;
    print("getttt");
    Future<DocumentSnapshot> docSnap = firestore.collection("conference").doc(id).snapshots().single;


    StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection("conference").doc(id).snapshots(),
      builder: (context, snapshot) {
        conf = Conference.fromSnapshot(snapshot.data);
        return;
      },
    );
    return conf;
  }
}