import 'package:cloud_firestore/cloud_firestore.dart';

class Conference {
  final String name;
  final int num_attendees;
  final DocumentReference reference;

  Conference(this.name, this.num_attendees, this.reference);

  Conference.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['num_attendees'] != null),
        name = map['name'],
        num_attendees = map['num_attendees'];

  Conference.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  Future<Conference> getFuture() async {
    return this;
  }

  @override
  String toString() => "Record<$name:$num_attendees>";
}
