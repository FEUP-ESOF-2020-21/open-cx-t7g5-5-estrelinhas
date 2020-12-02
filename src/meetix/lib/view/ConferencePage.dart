import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/controller/FunctionsController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/model/Conference.dart';
import 'package:meetix/view/AllProfilesPage.dart';
import 'package:meetix/view/MatchedProfilesPage.dart';
import 'package:meetix/view/TopProfilesPage.dart';
import 'package:meetix/view/EditConferencePage.dart';
import 'package:meetix/view/LikedYouProfilesPage.dart';
import 'package:provider/provider.dart';

import 'ConferenceListPage.dart';

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
  Widget build(BuildContext context){
    return showConferenceWorkspace(context);
  }

  Widget showConferenceWorkspace(BuildContext context) {
    return StreamBuilder(
      stream: widget._firestore.getConferenceById(widget._conference.reference.id),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          if(snapshot.data.size > 0)
            return _displayConferenceWorkspace(context, snapshot.data.docs.first);
          else {
            return Center(child: Text("This conference does not exist!"));
          }
        } else if (snapshot.hasError) {
          return Text("Error :(");
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _displayConferenceWorkspace(BuildContext context, DocumentSnapshot data) {
    Conference conference = Conference.fromSnapshot(data);

    return Scaffold(
      appBar: AppBar(
          title: Text(conference.name),
          actions: <Widget> [
            if(context.watch<AuthController>().currentUser.uid == conference.uid)
              _buildPopupMenu(context, conference)
          ],
      ),
      body: _buildBody(context, conference),

      bottomNavigationBar: _buildNavigationBar(),

    );
  }

  Widget _buildPopupMenu(BuildContext context, Conference conference){

    return PopupMenuButton(
        onSelected: (newValue){
          if(newValue == 0){
            Navigator.push(context, MaterialPageRoute(builder: (context) => EditConferencePage(widget._firestore, widget._storage, widget._functions, conference))).then((value) => setState(() {}));
          }
          else if(newValue == 1){
            confirmDialog(context, conference);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            child: Text("Edit Conference"),
            value: 0,
          ),
          PopupMenuItem(
            child: Text("Delete Conference"),
            value: 1,
          ),
        ],
    );
  }

  Widget _buildBody(BuildContext context, Conference conference) {
    return IndexedStack(
      index: _currentTab,
      children: [
        AllProfilesPage(widget._firestore, widget._storage, conference, hasProfile: widget.hasProfile,),
        TopProfilesPage(widget._firestore, widget._storage, widget._functions, conference, hasProfile: widget.hasProfile,),
        LikedYouProfilesPage(widget._firestore, widget._storage,  conference, hasProfile: widget.hasProfile,),
        MatchedProfilesPage(widget._firestore, widget._storage, conference, hasProfile: widget.hasProfile,),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return BottomNavigationBar(
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
    );
  }

  _confirmDelete(bool delete, BuildContext context, Conference conference){
    if(delete){
      widget._firestore.deleteConference(conference.reference.id);
      //delete storage
      Navigator.pop(context);
      Navigator.pop(context);
    }
    else {
      Navigator.pop(context);
    }
  }

  confirmDialog(BuildContext context, Conference conference){
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("Delete Conference"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Are you sure you want to delete this conference?"),
              ],
            )
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () => _confirmDelete(false, context, conference),
              child: Text("Cancel"),
            ),
            FlatButton(
              onPressed: () => _confirmDelete(true, context, conference),
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
