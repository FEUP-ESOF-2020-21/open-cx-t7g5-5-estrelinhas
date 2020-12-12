import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/controller/FunctionsController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/model/Conference.dart';
import 'package:meetix/view/ConferencePage.dart';
import 'package:meetix/view/CreateProfilePage.dart';
import 'package:meetix/view/MyWidgets.dart';
import 'package:provider/provider.dart';


class MyCreatedConferencesPage extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;
  final FunctionsController _functions;
  @required final Function(int) onChangeConfTab;

  MyCreatedConferencesPage(this._firestore, this._storage, this._functions, {this.onChangeConfTab});

  @override
  _MyCreatedConferencesPageState createState() {
    return _MyCreatedConferencesPageState();
  }
}

class _MyCreatedConferencesPageState extends State<MyCreatedConferencesPage> {
  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    // Gets stream from Firestore with the conference info
    return StreamBuilder<QuerySnapshot>(
      stream: widget._firestore.getCreatedConferences(context.watch<AuthController>().currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.size > 0) {
            return _buildList(context, snapshot.data.docs);
          } else {
            return Center(child: Text("You have not created any conference"));
          }
        } else if (snapshot.hasError) {
          return Text("Error :(");
        } else {
          return Center(child: CircularProgressIndicator());
        }
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
            return ConferencePage(widget._firestore, widget._storage,  widget._functions, conference, hasProfile: true, onChangeConfTab: widget.onChangeConfTab);
          } else {
            return CreateProfilePage(widget._firestore, widget._storage, widget._functions, conference, onChangeConfTab: widget.onChangeConfTab);
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