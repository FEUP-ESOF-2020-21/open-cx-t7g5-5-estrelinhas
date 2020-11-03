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
  TextEditingController nameController = TextEditingController();
  bool _nameValid = true;

  submitForm() {
    setState(() {
      (nameController.text.isEmpty || nameController.text.length < 3)? _nameValid = false : _nameValid = true;

      if (_nameValid) {
        widget._conference.reference.collection("profiles").add({'name':nameController.text});
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ConferenceProfilesPage(widget._firestore, widget._storage, widget._conference)));
      }
    });
  }

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
              buildNameField("Full Name", "Your Name", controller: nameController),
              buildTextField("Occupation", "Student"),
              buildTextField("Location", "Porto, Portugal"),
              buildTextField("E-mail", "example@email.com"),
              buildTextField("Phone Number", "+351999999999"),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {submitForm();},
        icon: Icon(Icons.save, color: Colors.white,),
        label: Text("Save"),
      ),
    );
  }

  Widget buildNameField(String labelText, String placeholder, {TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0, left: 10.0, right: 10.0),
      child: TextField(
        controller: controller,
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
          ),
          errorText: _nameValid? null : "Name too short!",
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, String placeholder, {TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0, left: 10.0, right: 10.0),
      child: TextField(
        controller: controller,
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
          ),
        ),
      ),
    );
  }

  Widget addPicture() {
    return Center(
      child: Stack(
        children: [
          AvatarWithBorder(
            radius: 65,
            image: NetworkImage("https://www.lewesac.co.uk/wp-content/uploads/2017/12/default-avatar.jpg"),
            borderColor: Theme.of(context).scaffoldBackgroundColor,
            backgroundColor: Colors.blue,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: AvatarWithBorder(
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