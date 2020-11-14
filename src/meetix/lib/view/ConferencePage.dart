import 'package:flutter/material.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/model/Conference.dart';
import 'package:meetix/view/AllProfilesPage.dart';

import 'LikedYouProfilesPage.dart';

class ConferencePage extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;
  final Conference _conference;
  final bool hasProfile;

  ConferencePage(this._firestore, this._storage, this._conference,
      {this.hasProfile = false});
  @override
  _ConferencePageState createState() => _ConferencePageState();
}

class _ConferencePageState extends State<ConferencePage> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._conference.name),
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [
          AllProfilesPage(widget._firestore, widget._storage, widget._conference, hasProfile: widget.hasProfile,),
          LikedYouProfilesPage(widget._firestore, widget._storage, widget._conference, hasProfile: widget.hasProfile,),
        ],
      ),
      // body: _buildBody(context, widget._conference),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profiles"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "Liked You"
          )
        ],
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
      ),
    );
  }
}
