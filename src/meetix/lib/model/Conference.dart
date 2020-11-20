import 'package:cloud_firestore/cloud_firestore.dart';

class Conference {
  final String name;
  final String img;
  final int num_attendees;
  final List<String> interests;
  final DocumentReference reference;

  Conference.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['num_attendees'] != null),
        name = map['name'],
        num_attendees = map['num_attendees'],
        img = map['img'],
        interests = map['interests']==null ? List<String>() : List<String>.from(map['interests']);

  Conference.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  Future<Conference> getFuture() async {
    return this;
  }

  @override
  String toString() => "Record<$name:$num_attendees>";
}
