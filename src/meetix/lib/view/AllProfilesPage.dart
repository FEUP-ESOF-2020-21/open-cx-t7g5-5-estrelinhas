import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/model/Conference.dart';
import 'MyWidgets.dart';

class AllProfilesPage extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;
  final Conference _conference;
  final bool hasProfile;

  AllProfilesPage(this._firestore, this._storage, this._conference,
      {this.hasProfile = false});

  @override
  _AllProfilesPageState createState() {
    return _AllProfilesPageState();
  }
}

class _AllProfilesPageState extends State<AllProfilesPage> {
  @override
  Widget build(BuildContext context) {
    return _buildBody(context, widget._conference);
  }

  Widget _buildBody(BuildContext context, Conference conference) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget._firestore.getConferenceProfiles(conference),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.size == 0)
            return Center(child: Text("No profiles"));
          else
            return ProfileListView(widget._firestore, widget._storage, widget._conference, widget.hasProfile, snapshot.data.docs, fromQuery: false,);
        } else if (snapshot.hasError) {
          return Text("Error :(");
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
