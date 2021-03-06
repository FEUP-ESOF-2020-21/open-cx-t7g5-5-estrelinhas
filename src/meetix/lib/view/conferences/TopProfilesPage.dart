import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/controller/FunctionsController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/model/Conference.dart';
import 'package:meetix/model/Profile.dart';
import 'package:meetix/view/profiles/ViewProfileDetailsPage.dart';
import 'package:provider/provider.dart';
import '../meetix_widgets/MyWidgets.dart';

class TopProfilesPage extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;
  final FunctionsController _functions;
  final Conference _conference;
  final bool hasProfile;

  TopProfilesPage(this._firestore, this._storage, this._functions, this._conference,
      {this.hasProfile = false});

  @override
  _TopProfilesPageState createState() {
    return _TopProfilesPageState();
  }
}

class _TopProfilesPageState extends State<TopProfilesPage> {
  @override
  Widget build(BuildContext context) {
    return _buildBody(context, widget._conference);
  }

  Widget _buildBody(BuildContext context, Conference conference) {
    return FutureBuilder<List<List<String>>>(
      future: widget._functions.getTop20(context.watch<AuthController>().currentUser.uid, widget._conference.reference.id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0)
            return _buildList(context, snapshot.data.cast());
          else {
            return Center(child: Text("No top profiles to show."));
          }
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString() + " Error with function :(");
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildList(BuildContext context, List<List<String>> profileIDs) {
    List<Widget> profiles = profileIDs.map((data) => _buildProfile(context, data)).toList();
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: profiles.length,
      separatorBuilder: (context, index) => Divider(
        height: 0,
        color: Colors.grey,
      ),
      itemBuilder: (context, index) => profiles[index],
    );
  }

  Widget _buildProfile(BuildContext context, List<String> profileID) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget._firestore.getProfileById(widget._conference, profileID[0]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.size > 0)
            return _buildListItem(context, snapshot.data.docs.first, profileID[1]);
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

  Widget _buildListItem(BuildContext context, DocumentSnapshot data, String num_match) {
    final profile = Profile.fromSnapshot(data);

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewProfileDetailsPage(
                      widget._conference,
                      profile.uid,
                      widget._firestore,
                      widget._storage,
                      hasProfile: widget.hasProfile,
                    )));
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          child: Column(
            children: [
              Row(
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
              Text(num_match + " " + ((num_match == "1")? "interest" : "interests") + " in common"),
            ],
          ),
        ),
      ),
    );
  }
}
