import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/view/ConferenceProfilesPage.dart';

import '../model/Conference.dart';
import '../controller/FirestoreController.dart';

class ConferenceListPage extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;

  ConferenceListPage(this._firestore, this._storage);

  @override
  _ConferenceListPageState createState() {
    return _ConferenceListPageState();
  }
}

class _ConferenceListPageState extends State<ConferenceListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meetix Conferences')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget._firestore.getConferences(),
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
    final record = Conference.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.name),
          leading: FutureBuilder(
            future: FirebaseStorage.instance.ref("conferences/fcf20/fcf20.png").getDownloadURL(),
            builder: (context, url) {
              if (!url.hasData) { return LinearProgressIndicator(); }
              return Image.network(url.data);
            },
          ),
          trailing: Text(record.num_attendees.toString()),
          onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => ConferenceProfilesPage(widget._firestore, record.reference.id))); },
        ),
      ),
    );
  }

  void _toConference() {

  }
}