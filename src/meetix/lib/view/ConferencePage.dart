import 'package:flutter/material.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/controller/FunctionsController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/model/Conference.dart';
import 'package:meetix/view/AllProfilesPage.dart';
import 'package:meetix/view/MatchedProfilesPage.dart';
import 'package:meetix/view/TopProfilesPage.dart';

import 'LikedYouProfilesPage.dart';

class ConferencePage extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;
  final FunctionsController _functions;
  final Conference _conference;
  final bool hasProfile;

  ConferencePage(this._firestore, this._storage, this._functions, this._conference,
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
          // AllProfilesPage(widget._firestore, widget._storage, widget._conference, hasProfile: widget.hasProfile,),
          TopProfilesPage(widget._firestore, widget._storage, widget._functions, widget._conference, hasProfile: widget.hasProfile,),
          LikedYouProfilesPage(widget._firestore, widget._storage,  widget._conference, hasProfile: widget.hasProfile,),
          MatchedProfilesPage(widget._firestore, widget._storage, widget._conference, hasProfile: widget.hasProfile,),
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
              icon: Icon(Icons.star),
              label: "Top Profiles",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "Liked You"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_people),
              label: "Matches"
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.blue,
      ),
    );
  }
}
