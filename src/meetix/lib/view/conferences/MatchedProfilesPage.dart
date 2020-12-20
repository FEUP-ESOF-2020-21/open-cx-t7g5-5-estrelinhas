import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/model/Conference.dart';
import 'package:provider/provider.dart';
import '../meetix_widgets/MyWidgets.dart';

class MatchedProfilesPage extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;
  final Conference _conference;
  final bool hasProfile;

  MatchedProfilesPage(this._firestore, this._storage, this._conference,
      {this.hasProfile = false});

  @override
  _MatchedProfilesPageState createState() {
    return _MatchedProfilesPageState();
  }
}

class _MatchedProfilesPageState extends State<MatchedProfilesPage> {
  @override
  Widget build(BuildContext context) {
    return _buildBody(context, widget._conference);
  }

  Widget _buildBody(BuildContext context, Conference conference) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget._firestore.getMatches(conference, context.watch<AuthController>().currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.size > 0)
            return ProfileListView(widget._firestore, widget._storage, widget._conference, widget.hasProfile, snapshot.data.docs, fromQuery: true,);
          else {
            return Center(child: Text("No profiles have matched yours"));
          }
        } else if (snapshot.hasError) {
          return Text("Error :(");
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
