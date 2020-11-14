import 'package:flutter/foundation.dart';
import 'package:meetix/model/Profile.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/view/MyWidgets.dart';

import '../model/Conference.dart';
import '../controller/FirestoreController.dart';

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
  bool _hasInterests = true;

  String profileImgPath;
  Map updates = Map<String,dynamic>();

  @override
  initState(){
    super.initState();

    profileImgPath = widget._profile.img;
    _selectedInterests = widget._profile.interests;
  }

  submitForm() {
    setState(() {
      (_nameController.text.isEmpty || _nameController.text.length >= 3)? _nameValid = true : _nameValid = false;
      (_occupationController.text.isEmpty || _occupationController.text.length >=3) ? _occValid = true : _occValid = false;
      (_locationController.text.isEmpty || _locationController.text.length >= 3)? _locationValid = true : _locationValid = false;
      (_emailController.text.isEmpty || RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(_emailController.text)) ? _emailValid = true : _emailValid = false;
      (_phoneController.text.isEmpty || RegExp(r"^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$").hasMatch(_phoneController.text)) ? _phoneValid = true : _phoneValid = false;
      // (_selectedInterests.isEmpty)? _hasInterests = false : _hasInterests = true;


      if(_nameValid && _occValid && _locationValid && _emailValid && _phoneValid && _hasInterests){
        if(_nameController.text.isNotEmpty)
          updates['name'] = _nameController.text;
        if(_occupationController.text.isNotEmpty)
          updates['occupation'] = _occupationController.text;
        if(_locationController.text.isNotEmpty)
          updates['location'] = _locationController.text;
        if(_emailController.text.isNotEmpty)
          updates['email'] = _emailController.text;
        if(_phoneController.text.isNotEmpty)
          updates['phone'] = _phoneController.text;
        if(!listEquals(widget._profile.interests, _selectedInterests))
          updates['interests'] = _selectedInterests;

        widget._profile.reference.update(updates);

        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile for " + widget._conference.name)),
      body: _buildBody(context),
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
              conference: widget._conference,
              profileImgPath: widget._profile.img,
              onPathChanged: (path) {profileImgPath = path;},
            ),

            SizedBox(height: 35),

            TextFieldWidget(
                labelText: "Full Name",
                hintText: widget._profile.name,
                hintWeight: FontWeight.w400,
                controller: _nameController,
                isValid: _nameValid,
            ),
            TextFieldWidget(
                labelText: "Occupation",
                hintText: widget._profile.occupation,
                hintWeight: FontWeight.w400,
                controller: _occupationController,
                isValid: _occValid,
            ),
            TextFieldWidget(
                labelText: "Location",
                hintText: widget._profile.location,
                hintWeight: FontWeight.w400,
                controller: _locationController,
                isValid: _locationValid,
            ),
            TextFieldWidget(
                labelText: "E-mail",
                hintText: widget._profile.email,
                hintWeight: FontWeight.w400,
                controller: _emailController,
                isValid: _emailValid,
                textInputType: TextInputType.emailAddress
            ),
            TextFieldWidget(
                labelText: "Phone Number",
                hintText: widget._profile.phone,
                hintWeight: FontWeight.w400,
                controller: _phoneController,
                isValid: _phoneValid,
                textInputType: TextInputType.phone
            ),

            SelectInterests(
              conference: widget._conference,
              selectedInterests: _selectedInterests,
              hasInterests: _hasInterests,
              onInterestsChanged: (selectedList) {_selectedInterests = selectedList;}
            ),
            SizedBox(height:20.0),
          ],
        ),
      ),
    );
  }
}
