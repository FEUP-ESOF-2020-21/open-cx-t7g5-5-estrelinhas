import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String name;
  final DocumentReference reference;
  final String img;
  final String organization;

  Profile.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        name = map['name'],
        img = map['img'],
        organization = map['organization'];

  Profile.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);
}
