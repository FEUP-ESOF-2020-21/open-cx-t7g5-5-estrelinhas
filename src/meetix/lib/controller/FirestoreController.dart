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

  Stream<QuerySnapshot> getLikedYouProfiles(Conference conference, String profileID) {
    return conference.reference.collection("likes").where('liked', arrayContains: profileID).snapshots();
  }

  Stream<QuerySnapshot> getProfileById(Conference conference, String profileID) {
    return conference.reference.collection("profiles").where('uid', isEqualTo: profileID).snapshots();
  }

  Stream<QuerySnapshot> getMatches(Conference conference, String profileID) {
    return conference.reference.collection("profiles").doc(profileID).collection("matches").snapshots();
  }

  void likeProfile(Conference conference, String profileID, String likedID) {
    conference.reference.collection("likes").doc(profileID)
        .set({"liked": FieldValue.arrayUnion([likedID])}, SetOptions(merge: true));
  }

  void checkMatch(Conference conference, String profileID, String likedID, {Function onMatch}) {
    conference.reference.collection("likes")
        .where(FieldPath.documentId, isEqualTo: likedID)
        .where('liked', arrayContains: profileID)
        .get()
        .then((value) => {
          if (value.size > 0)
            onMatch()
        })
        .catchError((error) => print(error));
  }

  void addMatch(Conference conference, String profileID, String likedID) {
    conference.reference.collection("profiles")
        .doc(profileID)
        .collection("matches")
        .doc(likedID)
        .set({'match':true});
    conference.reference.collection("profiles")
        .doc(likedID)
        .collection("matches")
        .doc(profileID)
        .set({'match':true});
  }
}