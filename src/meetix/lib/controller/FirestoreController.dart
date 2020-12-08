import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/Conference.dart';

class FirestoreController {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getConferences() {
    return firestore.collection("conference").snapshots();
  }

  CollectionReference getConferenceCollection() {
    return firestore.collection("conference");
  }

  Stream<QuerySnapshot> getMyProfilesFromJoinedConferences(String profileID) {
    return firestore.collectionGroup("profiles").where('uid', isEqualTo: profileID).snapshots();
  }

  Stream<QuerySnapshot> getConferenceProfiles(Conference conference) {
    return conference.reference.collection("profiles").snapshots();
  }

  Stream<QuerySnapshot> getLikedYouProfiles(Conference conference, String profileID) {
    return firestore.collectionGroup("likes")
        .where('conference_id', isEqualTo: conference.reference.id)
        .where('uid', isEqualTo: profileID)
        .where('match', isEqualTo: false).snapshots();
  }

  Stream<QuerySnapshot> getProfileById(Conference conference, String profileID) {
    return conference.reference.collection("profiles").where('uid', isEqualTo: profileID).snapshots();
  }

  Stream<QuerySnapshot> getConferenceById(String conferenceId) {
    return firestore.collection("conference").where(FieldPath.documentId, isEqualTo: conferenceId).snapshots();
  }

  Stream<QuerySnapshot> getMatches(Conference conference, String profileID) {
    return firestore.collectionGroup("likes")
        .where('conference_id', isEqualTo: conference.reference.id)
        .where('uid', isEqualTo: profileID)
        .where('match', isEqualTo: true).snapshots();
  }

  void addLike(Conference conference, String profileID, String likedID) {
    conference.reference.collection("profiles")
        .doc(profileID)
        .collection("likes")
        .doc(likedID)
        .set({
          "conference_id" : conference.reference.id,
          "profile_id" : profileID,
          "uid" : likedID,
          "match" : false
        });
  }

  void removeLike(Conference conference, String profileID, String likedID) {
    conference.reference.collection("profiles")
        .doc(profileID)
        .collection("likes")
        .doc(likedID)
        .delete();
  }

  void checkLikeMatch(Conference conference, String profileID, String likedID, {Function onLike, Function onMatch}) {
    conference.reference.collection("profiles")
        .doc(profileID).collection("likes")
        .doc(likedID).get()
        .then((value) {
          if (value.exists) {
            onLike();
            if (value.data()['match'])
              onMatch();
          }
        })
        .catchError((error) => print(error));
  }

  void addMatch(Conference conference, String profileID, String likedID) {
    conference.reference.collection("profiles")
        .doc(profileID)
        .collection("likes")
        .doc(likedID)
        .update({
          "match" : true
        });
    conference.reference.collection("profiles")
        .doc(likedID)
        .collection("likes")
        .doc(profileID)
        .update({
          "match" : true
        });
  }

  void removeMatch(Conference conference, String profileID, String likedID) {
    conference.reference.collection("profiles")
        .doc(likedID)
        .collection("likes")
        .doc(profileID)
        .update({
          "match" : false
        });
  }

  void checkMatchTransaction(Conference conference, String profileID, String likedID, {Function onMatch}) {
    firestore.runTransaction((transaction) async {
      DocumentReference likedRef = conference.reference
          .collection("profiles")
          .doc(likedID)
          .collection("likes")
          .doc(profileID);

      DocumentSnapshot likedDoc = await transaction.get(likedRef);

      if (likedDoc.exists) {
        DocumentReference profileRef = conference.reference
            .collection("profiles")
            .doc(profileID)
            .collection("likes")
            .doc(likedID);

        transaction.update(profileRef, {"match" : true});
        transaction.update(likedRef, {"match" : true});

        onMatch();
      }
    })
    .then((value) => null)
    .catchError((error) => print(error));
  }
}