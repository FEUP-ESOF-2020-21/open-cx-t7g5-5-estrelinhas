import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/controller/FunctionsController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/model/Conference.dart';
import 'package:meetix/view/AllProfilesPage.dart';
import 'package:meetix/view/MatchedProfilesPage.dart';
import 'package:meetix/view/SearchProfilePage.dart';
import 'package:meetix/view/TopProfilesPage.dart';
import 'package:meetix/view/EditConferencePage.dart';
import 'package:meetix/view/LikedYouProfilesPage.dart';
import 'package:provider/provider.dart';

import 'CreateConferencePage.dart';
import 'CreateProfilePage.dart';
import 'EditAccountPage.dart';
import 'MyWidgets.dart';
import 'ViewProfileDetailsPage.dart';


class ConferencePage extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;
  final FunctionsController _functions;
  final Conference _conference;
  final bool hasProfile;
  @required final Function(int) onChangeConfTab;

  ConferencePage(this._firestore, this._storage, this._functions, this._conference, {this.hasProfile = false, this.onChangeConfTab});
  @override
  _ConferencePageState createState() => _ConferencePageState();
}



class _ConferencePageState extends State<ConferencePage> {
  int _currentTab = 0;
  bool isCreator;

  @override
  void initState() {
    super.initState();
    isCreator = context.read<AuthController>().currentUser.uid == widget._conference.uid;
  }

  @override
  Widget build(BuildContext context){
    return showConferenceWorkspace(context);
  }

  void _toConferenceListRefresh() {
    Navigator.pop(context, true);
  }

  Widget showConferenceWorkspace(BuildContext context) {
    return StreamBuilder(
      stream: widget._firestore.getConferenceById(widget._conference.reference.id),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          if(snapshot.data.size > 0)
            return _displayConferenceWorkspace(context, snapshot.data.docs.first);
          else {
            return Container(
                color: Colors.white,
            );
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
      ),
      body: _buildBody(context, conference),
      drawer: _buildDrawer(context, conference),
      bottomNavigationBar: _buildNavigationBar(),
      floatingActionButton: (_currentTab == 0)? FloatingActionButton(
        onPressed: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => SearchProfilePage(conference, widget.hasProfile))); },
        backgroundColor: Colors.orange,
        child: Icon(Icons.search),
      ) : null,
    );
  }

  Widget _buildDrawer(BuildContext context, Conference conference){
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 153, 102, 1),
              ),
              child: Row (
                crossAxisAlignment: CrossAxisAlignment.start,
                children:  <Widget>[
                  CustomAvatar(
                    imgURL: conference.img,
                    source: widget._storage,
                    initials: conference.name[0],
                    radius: 24,
                  ),
                  Padding (
                    padding: EdgeInsets.all(11.0),
                    child: Text(conference.name,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: SizedBox()),
                ],
              ),
            ),
          ),

          Expanded(child:
            ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: <Widget>[
                widget.hasProfile ? _ListProfileTile(context, conference) : _ListCreateProfileTile(context, conference),
                if(isCreator) _ListStaffTile(context, conference),
                Padding(
                  padding: EdgeInsets.fromLTRB(14.0, 10.0, 10.0, 10.0),
                  child: Text("Conferences", style: TextStyle(color: Color.fromRGBO(255, 153, 102, 1),),),
                ),
                ListTile(
                  leading: Icon(Icons.add),
                  title: Text("Create Conference"),
                  onTap: (){
                    Navigator.popUntil(context, ModalRoute.withName("/"));
                    widget.onChangeConfTab(2);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CreateConferencePage(widget._firestore, widget._storage, widget._functions)));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.list),
                  title: Text("Available Conferences"),
                  onTap: (){
                    Navigator.popUntil(context, ModalRoute.withName("/")); /* Go to main page */
                    widget.onChangeConfTab(0);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.list),
                  title: Text("Joined Conferences"),
                  onTap: (){
                    Navigator.popUntil(context, ModalRoute.withName("/")); /* Go to main page */
                    widget.onChangeConfTab(1);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.list),
                  title: Text("Created Conferences"),
                  onTap: (){
                    Navigator.popUntil(context, ModalRoute.withName("/")); /* Go to main page */
                    widget.onChangeConfTab(2);
                  },
                ),
                Divider(),
                Padding(
                  padding: EdgeInsets.fromLTRB(14.0, 10.0, 10.0, 10.0),
                  child: Text("Settings", style: TextStyle(color: Color.fromRGBO(255, 153, 102, 1),),),
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text("Account settings"),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditAccountPage(widget._firestore, widget._storage, widget._functions)));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text("Logout"),
                  onTap: (){ Navigator.popUntil(context, ModalRoute.withName("/")); context.read<AuthController>().signOut(); },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ListProfileTile(BuildContext context, Conference conference) {
      return Column (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(14.0, 10.0, 10.0, 10.0),
            child: Text("This Conference", style: TextStyle(color: Color.fromRGBO(255, 153, 102, 1),),),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("My Profile"),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ViewProfileDetailsPage(
                            widget._conference,
                            context.watch<AuthController>().currentUser.uid,
                            widget._firestore,
                            widget._storage,
                            hasProfile: widget.hasProfile,
                          )
                  )
              ).then((value) => setState(() {}));
            }
          ),
          ListTile(
              leading: Icon(Icons.delete),
              title: Text("Leave Conference"),
              onTap: () {
                confirmDeleteDialog(context, conference, "D_PROFILE");
              }
          ),
          Divider(),
        ],
      );
  }

  Widget _ListCreateProfileTile(BuildContext context, Conference conference) {
    return Column (
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
            leading: Icon(Icons.add),
            title: Text("Join Conference"),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CreateProfilePage(widget._firestore, widget._storage, widget._functions, conference))).then((value) => setState(() {}));
            }
        ),
        Divider(),
      ],
    );
  }

  Widget _ListStaffTile(BuildContext context, Conference conference) {
    return Column (
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(14.0, 10.0, 10.0, 10.0),
          child: Text("Staff", style: TextStyle(color: Color.fromRGBO(255, 153, 102, 1),),),
        ),
        ListTile(
            leading: Icon(Icons.person),
            title: Text("Edit Conference"),
            onTap: () {
              Navigator.pop(context); /* Close drawer */
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditConferencePage(widget._firestore, widget._storage, widget._functions, conference,))).then((value) => setState(() {}));
            }
        ),

        ListTile(
            leading: Icon(Icons.delete),
            title: Text("Delete Conference"),
            onTap: () {
              confirmDeleteDialog(context, conference, "D_CONFERENCE");
            }
        ),
        Divider(),
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
    );
  }

  _actionDeleteConference(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Deleting conference..."),
          children: [
            Center(
              child: CircularProgressIndicator(),
            ),
         ]
        );
      },
    );
    await widget._functions.deleteConference(widget._conference.reference.id);
    Navigator.pop(context); // Close dialog
    Navigator.pop(context); // Close drawer
    _toConferenceListRefresh(); // Go back to ConferenceListPage and refresh
  }
  
  _actionDeleteProfile(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Deleting profile..."),
          children: [
            Center(
              child: CircularProgressIndicator(),
            ),
         ]
        );
      },
    );
    await widget._functions.deleteProfile(widget._conference.reference.id, context.read<AuthController>().currentUser.uid);
    Navigator.popUntil(context, ModalRoute.withName('/')); // Close dialog
  }

  confirmDeleteDialog(BuildContext context, Conference conference, String action) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context){
        if (action == "D_CONFERENCE") {
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
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style:TextStyle(color: Color.fromRGBO(255, 153, 102, 1))),
              ),
              FlatButton(
                onPressed: () => _actionDeleteConference(context),
                child: Text("Delete", style:TextStyle(color: Color.fromRGBO(255, 153, 102, 1))),
              ),
            ],
          );
        } else if (action == "D_PROFILE") {
          return AlertDialog(
            title: Text("Delete Profile"),
            content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text("Are you sure you want to delete your profile for this conference?"),
                  ],
                )
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style:TextStyle(color: Color.fromRGBO(255, 153, 102, 1))),
              ),
              FlatButton(
                onPressed: () => _actionDeleteProfile(context),
                child: Text("Delete", style:TextStyle(color: Color.fromRGBO(255, 153, 102, 1))),
              ),
            ],
          );
        } else {
          return SimpleDialog(title: Text("INVALID"),);
        }
      },
    );
  }
}
