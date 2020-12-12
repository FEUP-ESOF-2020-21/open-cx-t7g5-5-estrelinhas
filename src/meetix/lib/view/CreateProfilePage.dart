import 'dart:io';

import 'package:meetix/controller/AuthController.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/controller/FunctionsController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/model/Conference.dart';
import 'package:meetix/view/ConferencePage.dart';
import 'package:meetix/view/MyWidgets.dart';
import 'package:provider/provider.dart';


class CreateProfilePage extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;
  final Conference _conference;
  final FunctionsController _functions;
  @required final Function(int) onChangeConfTab;

  CreateProfilePage(this._firestore, this._storage,  this._functions, this._conference, {this.onChangeConfTab});

  @override
  _CreateProfilePageState createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _occupationController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  List<String> _selectedInterests = List<String>();

  bool _nameValid = true;
  bool _occValid = true;
  bool _locationValid = true;
  bool _emailValid = true;
  bool _phoneValid = true;
  String profileImgUrl = 'default-avatar.jpg';
  File profileImg;

  submitForm() async {
    setState(() {
      _nameController.text = _nameController.text.trim();
      _occupationController.text = _occupationController.text.trim();
      _locationController.text = _locationController.text.trim();
      _emailController.text = _emailController.text.trim();
      _phoneController.text = _phoneController.text.trim();

      _nameValid = _nameController.text.isNotEmpty && _nameController.text.length >= 3;
      _occValid = _occupationController.text.isNotEmpty;
      _locationValid = _locationController.text.isNotEmpty;
      _emailValid = _emailController.text.isNotEmpty && RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(_emailController.text);
      _phoneValid = _phoneController.text.isNotEmpty && RegExp(r"^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$").hasMatch(_phoneController.text);
    });

    if (_nameValid && _occValid && _locationValid && _emailValid && _phoneValid) {
      if(profileImg != null){
        profileImgUrl = 'conferences/' + widget._conference.reference.id + '/profiles/' + context.read<AuthController>().currentUser.uid + '/profile_img';
        await widget._storage.uploadFile(profileImgUrl, profileImg);
      }

      widget._conference.reference.collection("profiles").doc(context.read<AuthController>().currentUser.uid).set({'uid':context.read<AuthController>().currentUser.uid,
        'name':_nameController.text,
        'occupation':_occupationController.text,
        'location':_locationController.text,
        'email':_emailController.text,
        'phone':_phoneController.text,
        'img':profileImgUrl,
        'interests':_selectedInterests
      });

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ConferencePage(widget._firestore, widget._storage, widget._functions, widget._conference, hasProfile: true, onChangeConfTab: widget.onChangeConfTab)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My profile for " + widget._conference.name)),
      body: _buildBody(context),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ConferencePage(widget._firestore, widget._storage, widget._functions, widget._conference, onChangeConfTab: widget.onChangeConfTab)));
                },
                child: Text("Skip", style: TextStyle(color: Colors.grey),)
              ),
              SizedBox(width: 20,),
              RaisedButton(
                onPressed: (){submitForm();},
                child: Text("Next", style: TextStyle(color: Colors.white),), color: Theme.of(context).accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          children: [
            SizedBox(height: 15),

            ShowAvatarEdit(
              storage: widget._storage,
              profileImgUrl: profileImgUrl,
              onFileChosen: (file) {profileImg = file;},
            ),

            SizedBox(height: 35),

            TextFieldWidget(
                labelText: "Full Name",
                hintText: "Your Name",
                controller: _nameController,
                isValid: _nameValid,
            ),
            TextFieldWidget(
                labelText: "Occupation",
                hintText: "Student",
                controller: _occupationController,
                isValid: _occValid,
            ),
            TextFieldWidget(
                labelText: "Location",
                hintText: "Porto, Portugal",
                controller: _locationController,
                isValid: _locationValid,
            ),
            TextFieldWidget(
                labelText: "E-mail",
                hintText: "example@email.com",
                controller: _emailController,
                isValid: _emailValid,
                textInputType: TextInputType.emailAddress
            ),
            TextFieldWidget(
                labelText: "Phone Number",
                hintText: "912345678",
                controller: _phoneController,
                isValid: _phoneValid,
                textInputType: TextInputType.phone
            ),

            SelectInterests(
                conference: widget._conference,
                selectedInterests: _selectedInterests,
                onInterestsChanged: (selectedList) {_selectedInterests = selectedList;}
            ),
            SizedBox(height:20.0),
          ],
        ),
      ),
    );
  }
}


