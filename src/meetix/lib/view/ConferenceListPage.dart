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
    // Gets stream from Firestore with the conference info
    return StreamBuilder<QuerySnapshot>(
      stream: widget._firestore.getConferences(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.docs);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    List<Widget> conferences =  snapshot.map((data) => _buildListItem(context, data)).toList();
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: conferences.length,
      separatorBuilder: (context, index) => Divider(height: 0, color: Colors.grey,),
      itemBuilder: (context, index) => conferences[index],
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final _conference = Conference.fromSnapshot(data);

    return InkWell(
      onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => ConferenceProfilesPage(widget._firestore, _conference.reference.id))); },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Displays conference icon, if null, displays initial
            (_conference.img != null)?
              FutureBuilder(
                future: widget._storage.getImgURL(_conference.img),
                builder: (context, url) {
                  if (url.hasError) {
                    return Icon(Icons.error);
                  } else if (url.hasData) {
                    return CircleAvatar(backgroundImage: NetworkImage(url.data));
                  } else {
                    return SizedBox(width: 40, height: 40, child: CircularProgressIndicator());
                  }
                },
              ) :
              CircleAvatar(
                child: Text(_conference.name[0]),
                backgroundColor: Theme.of(context).primaryColorLight,
              ),
            SizedBox(width: 16.0,),
            Text(_conference.name,
              style: Theme.of(context).textTheme.headline6,
            ),
            Expanded(child: SizedBox()),
            Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.grey,),
          ],
        ),
      ),
    );
  }
}