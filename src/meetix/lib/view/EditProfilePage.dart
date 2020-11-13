import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:meetix/model/Profile.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/view/ConferenceProfilesPage.dart';
import 'package:meetix/view/MyWidgets.dart';
import 'package:provider/provider.dart';

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

    profileImgPath = 'conferences/' + widget._conference.reference.id + '/profiles/' + context.read<AuthController>().currentUser.uid + '/profile_img';
    _selectedInterests = widget._profile.interests;
    print(widget._profile.name);
    print(widget._profile.interests);
    print(_selectedInterests);
  }

  submitForm() {
    setState(() {
      (_nameController.text.isEmpty || _nameController.text.length >= 3)? _nameValid = true : _nameValid = false;
      (_occupationController.text.isEmpty || _occupationController.text.length >=3) ? _occValid = true : _occValid = false;
      (_locationController.text.isEmpty || _locationController.text.length >= 3)? _locationValid = true : _locationValid = false;
      (_emailController.text.isEmpty || RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(_emailController.text)) ? _emailValid = true : _emailValid = false;
      (_phoneController.text.isEmpty || RegExp(r"^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$").hasMatch(_phoneController.text)) ? _phoneValid = true : _phoneValid = false;
      (_selectedInterests.isEmpty)? _hasInterests = false : _hasInterests = true;
      print(_selectedInterests);
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

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ConferenceProfilesPage(widget._firestore, widget._storage, widget._conference)));
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
            _showPicture(),
            SizedBox(height: 35),
            TextFieldWidget("Full Name", widget._profile.name, _nameController, _nameValid, false),
            TextFieldWidget("Occupation", widget._profile.occupation, _occupationController, _occValid, false),
            TextFieldWidget("Location", widget._profile.location, _locationController, _locationValid, false),
            TextFieldWidget("E-mail", widget._profile.email, _emailController, _emailValid, false),
            TextFieldWidget("Phone Number", widget._profile.phone, _phoneController, _phoneValid, false),
            _selectInterests(),
            SizedBox(height:20.0),
          ],
        ),
      ),
    );
  }


  Widget _showPicture() {
    return GestureDetector(
      onTap: () {uploadImage();},
      child: Center(
        child: Stack(
          children: [
            AvatarWithBorder(
              radius: 65,
              imgURL: widget._profile.img,
              source: widget._storage,
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
      ),
    );
  }

  uploadImage() async {
    final _picker = ImagePicker();
    PickedFile image;

    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;

    if(permissionStatus.isGranted){
      image = await _picker.getImage(source: ImageSource.gallery);
      if(image != null){
        var file = File(image.path);

        await widget._storage.uploadFile(profileImgPath, file);

        setState(() {});
      }
      else {
        print('No path Received');
      }
    }
    else {
      print('Grant permission and try again!');
    }
  }

  Widget _selectInterests() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if(_selectedInterests.isNotEmpty) InterestsWrap(_selectedInterests)
          else
            if(!_hasInterests)
              Text(
                "No interests selected!",
                style: TextStyle(color: Colors.red),
              ),
          RaisedButton(
            child: Text("Change Interests"),
            onPressed: () => _showInterestsDialog(widget._conference.interests),
          ),
        ],
      ),
    );
  }

  _showInterestsDialog(List<String> interests) {
    List<String> _currentSelection = List<String>();

    showDialog(
        context: context,
        builder: (BuildContext context) {

          //Here we will build the content of the dialog
          return AlertDialog(
            title: Text("Interests"),
            content: MultiSelectChip(
              interests,
              onSelectionChanged: (selectedList) {
                _currentSelection = selectedList;
              },
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Submit"),
                onPressed: () {
                  setState(() {
                    _selectedInterests = _currentSelection;
                    (_selectedInterests.isEmpty)? _hasInterests = false : _hasInterests = true;
                  });
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}


