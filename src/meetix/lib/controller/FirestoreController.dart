import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../model/Conference.dart';

class FirestoreController {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getConferences() {
    return firestore.collection("conference").snapshots();
  }

  Stream<QuerySnapshot> getConferenceProfiles(Conference conference) {
    return conference.reference.collection("profiles").snapshots();
  }
}