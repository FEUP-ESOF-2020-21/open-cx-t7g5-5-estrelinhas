import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/model/Profile.dart';
import 'package:meetix/view/ViewProfileDetailsPage.dart';
import 'package:provider/provider.dart';

import '../model/Conference.dart';
import '../controller/FirestoreController.dart';
import 'MyWidgets.dart';

class LikedYouProfilesPage extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;
  final Conference _conference;
  final bool hasProfile;

  LikedYouProfilesPage(this._firestore, this._storage, this._conference,
      {this.hasProfile = false});

  @override
  _LikedYouProfilesPageState createState() {
    return _LikedYouProfilesPageState();
  }
}

class _LikedYouProfilesPageState extends State<LikedYouProfilesPage> {
  @override
  Widget build(BuildContext context) {
    return _buildBody(context, widget._conference);
  }

  Widget _buildBody(BuildContext context, Conference conference) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget._firestore.getLikedYouProfiles(
          conference, context.watch<AuthController>().currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.size > 0)
            return ProfileListView(widget._firestore, widget._storage, widget._conference, widget.hasProfile, snapshot.data.docs, fromQuery: true,);
          else {
            return Center(child: Text("No profiles have liked you :("));
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
