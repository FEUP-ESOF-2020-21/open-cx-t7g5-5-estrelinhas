import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/model/Conference.dart';
import 'package:meetix/model/Profile.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/view/MyWidgets.dart';


class EditProfilePage extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;
  final Conference _conference;
  final Profile _profile;

  EditProfilePage(this._firestore, this._storage, this._conference, this._profile);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _occupationController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  List<String> _selectedInterests;

  bool _nameValid = true;
  bool _occValid = true;
  bool _locationValid = true;
  bool _emailValid = true;
  bool _phoneValid = true;

  String profileImgUrl;
  File profileImg;
  Map updates = Map<String,dynamic>();

  @override
  initState(){
    super.initState();

    profileImgUrl = widget._profile.img;
    _selectedInterests = widget._profile.interests;
  }

  submitForm() async{
    setState(() {
      _nameController.text = _nameController.text.trim();
      _occupationController.text = _occupationController.text.trim();
      _locationController.text = _locationController.text.trim();
      _emailController.text = _emailController.text.trim();
      _phoneController.text = _phoneController.text.trim();

      _nameValid = _nameController.text.isEmpty || _nameController.text.length >= 3;
      _occValid = true;
      _locationValid = true;
      _emailValid = _emailController.text.isEmpty || RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(_emailController.text);
      _phoneValid = _phoneController.text.isEmpty || RegExp(r"^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$").hasMatch(_phoneController.text);
    });

    if(_nameValid && _occValid && _locationValid && _emailValid && _phoneValid){
      if(profileImg != null){
        profileImgUrl = 'conferences/' + widget._conference.reference.id + '/profiles/' + widget._profile.uid + '/profile_img';
        await widget._storage.uploadFile(profileImgUrl, profileImg);
      }

      if(profileImgUrl != widget._profile.img)
        updates['img'] = profileImgUrl;
      if(_nameController.text.isNotEmpty && _nameController.text != widget._profile.name)
        updates['name'] = _nameController.text;
      if(_occupationController.text.isNotEmpty && _occupationController.text != widget._profile.occupation)
        updates['occupation'] = _occupationController.text;
      if(_locationController.text.isNotEmpty && _locationController.text != widget._profile.location)
        updates['location'] = _locationController.text;
      if(_emailController.text.isNotEmpty && _emailController.text != widget._profile.email)
        updates['email'] = _emailController.text;
      if(_phoneController.text.isNotEmpty && _phoneController.text != widget._profile.phone)
        updates['phone'] = _phoneController.text;
      if(!listEquals(widget._profile.interests, _selectedInterests))
        updates['interests'] = _selectedInterests;

      widget._profile.reference.update(updates);

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile for " + widget._conference.name)),
      body: Builder(builder: (context) => _buildBody(context)),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("Cancel", style: TextStyle(color: Colors.grey),)
              ),
              SizedBox(width: 20,),
              RaisedButton(
                onPressed: (){submitForm();},
                child: Text("Save changes", style: TextStyle(color: Colors.white),), color: Theme.of(context).accentColor,
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
              profileImgUrl: widget._profile.img,
              onFileChosen: (file) {profileImg = file;},
            ),

            SizedBox(height: 35),

            TextFieldWidget(
                labelText: "Full Name",
                hintText: widget._profile.name,
                hintWeight: FontWeight.w400,
                controller: _nameController,
                isValid: _nameValid,
                defaultValue: widget._profile.name,
            ),
            TextFieldWidget(
                labelText: "Occupation",
                hintText: widget._profile.occupation,
                hintWeight: FontWeight.w400,
                controller: _occupationController,
                isValid: _occValid,
                defaultValue: widget._profile.occupation,
            ),
            TextFieldWidget(
                labelText: "Location",
                hintText: widget._profile.location,
                hintWeight: FontWeight.w400,
                controller: _locationController,
                isValid: _locationValid,
                defaultValue: widget._profile.location,
            ),
            TextFieldWidget(
                labelText: "E-mail",
                hintText: widget._profile.email,
                hintWeight: FontWeight.w400,
                controller: _emailController,
                isValid: _emailValid,
                textInputType: TextInputType.emailAddress,
                defaultValue: widget._profile.email,
            ),
            TextFieldWidget(
                labelText: "Phone Number",
                hintText: widget._profile.phone,
                hintWeight: FontWeight.w400,
                controller: _phoneController,
                isValid: _phoneValid,
                textInputType: TextInputType.phone,
                defaultValue: widget._profile.phone,
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
