import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:meetix/controller/FunctionsController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/view/ConferencePage.dart';
import 'package:meetix/view/CreateConferencePage.dart';
import 'package:meetix/view/CreateProfilePage.dart';
import 'package:meetix/view/MyWidgets.dart';
import 'package:provider/provider.dart';

import '../model/Conference.dart';
import '../controller/FirestoreController.dart';

class ConferenceListPage extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;
  final FunctionsController _functions;

  ConferenceListPage(this._firestore, this._storage, this._functions);

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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 150,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Meetix",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Text(
                      "Welcome " + context.watch<AuthController>().currentUser.displayName + "!",
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white
                      ),
                    ),
                    SizedBox(height: 8,)
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text("Create Conference"),
              onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => CreateConferencePage(widget._firestore, widget._storage, widget._functions))); },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text("Joined Conferences"),
              //onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => CreateConferencePage(widget._firestore, widget._storage, widget._functions))); },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text("Available Conferences"),
              //onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => CreateConferencePage(widget._firestore, widget._storage, widget._functions))); },
            ),
            Divider(
              color: Colors.black,
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Account Settings"),
              //onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => CreateConferencePage(widget._firestore, widget._storage, widget._functions))); },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: (){ context.read<AuthController>().signOut(); },
            )
          ],
        ),
      ),
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
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => openConference(context, _conference))).then((value) => setState((){}));
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Displays conference icon, if null, displays initial
            CustomAvatar(
              imgURL: _conference.img,
              source: widget._storage,
              initials: _conference.name[0],
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

  Widget openConference(BuildContext context, Conference conference) {
    return FutureBuilder(
      future: conference.reference.collection('profiles').where('uid', isEqualTo: context.watch<AuthController>().currentUser.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.size > 0) {
            return ConferencePage(widget._firestore, widget._storage,  widget._functions, conference, hasProfile: true,);
          } else {
            return CreateProfilePage(widget._firestore, widget._storage, widget._functions, conference);
          }
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text(snapshot.error.toString()),),);
        } else {
          return Scaffold(body: Center(child: CircularProgressIndicator(),),);
        }
      },
    );
  }
}
