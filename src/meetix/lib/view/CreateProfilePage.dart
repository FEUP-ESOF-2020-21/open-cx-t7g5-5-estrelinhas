import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/view/ConferenceProfilesPage.dart';
import 'package:meetix/view/MyWidgets.dart';
import 'package:provider/provider.dart';

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
  bool _hasInterests = true;
  String profileImgPath = 'default-avatar.jpg';

  submitForm() {
    setState(() {
      (_nameController.text.isEmpty || _nameController.text.length < 3)? _nameValid = false : _nameValid = true;
      (_occupationController.text.isEmpty) ? _occValid = false : _occValid = true;
      (_locationController.text.isEmpty)? _locationValid = false : _locationValid = true;
      (_emailController.text.isEmpty || !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(_emailController.text)) ? _emailValid = false : _emailValid = true;
      (_phoneController.text.isEmpty || !RegExp(r"^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$").hasMatch(_phoneController.text)) ? _phoneValid = false : _phoneValid = true;
      (_selectedInterests.isEmpty)? _hasInterests = false : _hasInterests = true;
      print(_selectedInterests);

      if (_nameValid && _occValid && _locationValid && _emailValid && _phoneValid && _hasInterests) {
        widget._conference.reference.collection("profiles").add({'uid':context.read<AuthController>().currentUser.uid,
                                                                  'name':_nameController.text,
                                                                  'occupation':_occupationController.text,
                                                                  'location':_locationController.text,
                                                                  'email':_emailController.text,
                                                                  'phone':_phoneController.text,
                                                                  'img':profileImgPath,
                                                                  'interests':_selectedInterests
        });


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
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ConferenceProfilesPage(widget._firestore, widget._storage, widget._conference)));
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
            _showPicture(),
            SizedBox(height: 35),
            TextFieldWidget("Full Name", "Your Name", _nameController, _nameValid, true),
            TextFieldWidget("Occupation", "Student", _occupationController, _occValid, true),
            TextFieldWidget("Location", "Porto, Portugal", _locationController, _locationValid, true),
            TextFieldWidget("E-mail", "example@email.com", _emailController, _emailValid, true),
            TextFieldWidget("Phone Number", "+351999999999", _phoneController, _phoneValid, true),
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
              imgURL: profileImgPath,
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
        profileImgPath = 'conferences/' + widget._conference.reference.id + '/profiles/' + context.read<AuthController>().currentUser.uid + '/profile_img';

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
          child: Text("Select Interests"),
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


