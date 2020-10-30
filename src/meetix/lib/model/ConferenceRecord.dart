import 'package:cloud_firestore/cloud_firestore.dart';

class ConferenceRecord {
  final String name;
  final int num_attendees;
  final DocumentReference reference;

  ConferenceRecord.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['num_attendees'] != null),
        name = map['name'],
        num_attendees = map['num_attendees'];

  ConferenceRecord.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$num_attendees>";
}
