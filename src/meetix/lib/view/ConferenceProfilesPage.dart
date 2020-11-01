import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meetix/model/Profile.dart';

import '../model/Conference.dart';
import '../controller/FirestoreController.dart';

class ConferenceProfilesPage extends StatefulWidget {
  final FirestoreController _firestore;
  final String _conferenceID;

  ConferenceProfilesPage(this._firestore, this._conferenceID);

  @override
  _ConferenceProfilesPageState createState() {
    return _ConferenceProfilesPageState();
  }
}

class _ConferenceProfilesPageState extends State<ConferenceProfilesPage> {
  Conference _conference;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("conference").doc(widget._conferenceID).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildPage(snapshot.data);
      },
    );
  }

  Widget _buildPage(DocumentSnapshot data) {
    return Scaffold(
      appBar: AppBar(title: Text(data.data()["name"])),
      body: _buildBody(context, data),
    );
  }

  Widget _buildBody(BuildContext context, DocumentSnapshot data) {
    return StreamBuilder<QuerySnapshot>(
      stream: data.reference.collection("profiles").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.docs);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final profile = Profile.fromSnapshot(data);

    return Padding(
      key: ValueKey(profile.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(profile.name),
        ),
      ),
    );
  }
}