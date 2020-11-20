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
            return _buildList(context, snapshot.data.docs);
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

  Widget _buildList(
      BuildContext context, List<QueryDocumentSnapshot> snapshot) {
    List<Widget> profiles =
        snapshot.map((data) => _buildProfile(context, data)).toList();
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: profiles.length,
      separatorBuilder: (context, index) => Divider(
        height: 0,
        color: Colors.grey,
      ),
      itemBuilder: (context, index) => profiles[index],
    );
  }

  Widget _buildProfile(BuildContext context, DocumentSnapshot data) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget._firestore.getProfileById(widget._conference, data.data()['profile_id']),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.size > 0)
            return _buildListItem(context, snapshot.data.docs.first);
          else {
            return Center(child: Text("This profile does not exist!"));
          }
        } else if (snapshot.hasError) {
          return Text("Error :(");
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final profile = Profile.fromSnapshot(data);

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewProfileDetailsPage(
                      widget._conference,
                      profile,
                      widget._firestore,
                      widget._storage,
                      hasProfile: widget.hasProfile,
                    )));
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CustomAvatar(
              imgURL: profile.img,
              source: widget._storage,
              initials: profile.name[0],
              radius: 60,
            ),
            SizedBox(
              width: 20.0,
            ),
            ProfileOccupationDisplay(
              profile: profile,
            ),
            SizedBox(
              width: 20.0,
            ),
            // Expanded(child: SizedBox(),),
            Icon(
              Icons.connect_without_contact_rounded,
              color: Colors.grey,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }
}
