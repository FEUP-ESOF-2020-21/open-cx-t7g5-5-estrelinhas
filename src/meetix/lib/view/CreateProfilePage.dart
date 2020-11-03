import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/view/ConferenceProfilesPage.dart';
import 'package:meetix/model/Profile.dart';
import 'package:meetix/view/MyWidgets.dart';

import '../model/Conference.dart';
import '../controller/FirestoreController.dart';

class CreateProfilePage extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;
  final Conference _conference;

  CreateProfilePage(this._firestore, this._storage, this._conference);

  @override
  _CreateProfilePageState createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile for " + widget._conference.name)),
      body: Container(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              SizedBox(height: 15,),
              addPicture(),
              SizedBox(height: 35,),
              buildTextField("Full Name", "Your Name"),
              buildTextField("Occupation", "Student"),
              buildTextField("Location", "Porto, Portugal"),
              buildTextField("E-mail", "example@email.com"),
              buildTextField("Phone Number", "+351999999999"),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ConferenceProfilesPage(widget._firestore, widget._storage, widget._conference))); },
        icon: Icon(Icons.save, color: Colors.white,),
        label: Text("Save"),
      ),
    );
  }

  Widget buildTextField(String labelText, String placeholder) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0, left: 10.0, right: 10.0),
      child: TextField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: labelText,
          labelStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: placeholder,
          hintStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w100,
            color: Colors.black,
          )
        ),
      ),
    );
  }

  Widget addPicture() {
    return Center(
      child: Stack(
        children: [
          avatarWithBorder(
            radius: 65,
            image: NetworkImage("https://www.lewesac.co.uk/wp-content/uploads/2017/12/default-avatar.jpg"),
            borderColor: Theme.of(context).scaffoldBackgroundColor,
            backgroundColor: Colors.blue,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: avatarWithBorder(
              border: 4,
              icon: Icon(Icons.edit, color: Colors.white,),
              borderColor: Theme.of(context).scaffoldBackgroundColor,
              backgroundColor: Theme.of(context).accentColor,
            ),
          ),
        ],
      ),
    );
  }
}