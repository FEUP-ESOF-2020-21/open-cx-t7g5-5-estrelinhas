import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final DocumentReference reference;
  final String img;
  final String name;
  final String occupation;
  final String location;
  final String email;
  final String phone;
  final List<String> interests;
  final String uid;

  Profile.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        img = map['img'],
        name = map['name'],
        occupation = map['occupation'],
        location = map['location'],
        email = map['email'],
        phone = map['phone'],
        interests = map['interests']==null ? List<String>() : List<String>.from(map['interests']),
        uid = map['uid'];


  Profile.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);
}