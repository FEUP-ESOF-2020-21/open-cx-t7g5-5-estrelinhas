import 'package:cloud_firestore/cloud_firestore.dart';

class Conference {
  final String name;
  final String img;
  final List<String> interests;
  final String uid;
  final DateTime start_date;
  final DateTime end_date;
  final DocumentReference reference;

  Conference.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        name = map['name'],
        img = map['img'],
        interests = map['interests']==null ? List<String>() : List<String>.from(map['interests']),
        uid = map['uid'],
        start_date = map['start_date'].toDate(),
        end_date = map['end_date'].toDate();

  Conference.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  Future<Conference> getFuture() async {
    return this;
  }

}
