import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/view/ConferenceProfilesPage.dart';
import 'package:meetix/view/MyWidgets.dart';
import 'package:meetix/model/Profile.dart';

import '../model/Conference.dart';
import '../controller/FirestoreController.dart';



class Profile extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;

  Profile(this._firestore, this._storage);

  @override
  _ProfileState createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Meetix '),
          centerTitle: true,
          backgroundColor: Colors.blue,
          elevation: 2 ,
          actions: [
            IconButton(
            icon:Icon(
              Icons.cancel_outlined,
              size: 30,
              color:Colors.white,
            ),
              onPressed:(){
                Navigator.pop(context);
              }

            )
          ]
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton.extended(

        icon: Icon(Icons.thumb_up_sharp, color: Colors.white,),

        label: Text("Like"),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
   /* // Gets stream from Firestore with the conference info
    return StreamBuilder<QuerySnapshot>(
      stream: widget._firestore.getConferences(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildAva(context, snapshot.data.docs);
      },
    );*/
    return ListView(
      children:[
        _buildAva(context),
        _buildNameField(context),
        _buildInfoList(context),

      ]
    );
  }
  Widget _buildNameField(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.only(top: 50.0),
        child: Center(
        child: Column(
          children:[
          Text("JOANA SILVA",
          style: Theme.of(context).textTheme.headline6,
          ),
            ]

        ),
        )
    );
  }

  Widget _buildInfoList(BuildContext context) {
    return  InkWell(
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child:Column(
                children:[
                  Text("Ocupation",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Text("Location",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ]

            ),


    )
    );
  }


 Widget _buildAva(BuildContext context){
    return Padding(
        padding: const EdgeInsets.only(top: 35.0),
        child: Center(
          child:Stack(
            children:[
              CircleAvatar(
                radius: 65,
                //image: NetworkImage("https://www.lewesac.co.uk/wp-content/uploads/2017/12/default-avatar.jpg"),
                backgroundColor: Colors.blue,
              ),
            ],
          ),
        )
    );

  }


/*  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
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
      onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => ConferenceProfilesPage(widget._firestore, widget._storage, _conference))); },
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
  }*/
}