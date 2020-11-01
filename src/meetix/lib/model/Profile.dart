import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String name;
  final DocumentReference reference;

  Profile(this.name, this.reference);

  Profile.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        name = map['name'];

  Profile.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);
}
