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

  bool _nameValid = true;
  bool _occValid = true;
  bool _locationValid = true;
  bool _emailValid = true;
  bool _phoneValid = true;

  String profileImg = "https://www.lewesac.co.uk/wp-content/uploads/2017/12/default-avatar.jpg";
  String profileImgPath;

  @override
  initState(){
    super.initState();

    profileImgPath = 'conferences/' + widget._conference.reference.id + '/profiles/' + context.read<AuthController>().currentUser.uid + '/profile_img';
  }

  submitForm() {
    setState(() {
      (_nameController.text.isEmpty || _nameController.text.length < 3)? _nameValid = false : _nameValid = true;
      (_occupationController.text.isEmpty) ? _occValid = false : _occValid = true;
      (_locationController.text.isEmpty)? _locationValid = false : _locationValid = true;
      (_emailController.text.isEmpty || !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(_emailController.text)) ? _emailValid = false : _emailValid = true;
      (_phoneController.text.isEmpty || !RegExp(r"^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$").hasMatch(_phoneController.text)) ? _phoneValid = false : _phoneValid = true;


      if (_nameValid && _occValid && _locationValid && _emailValid && _phoneValid) {
        widget._conference.reference.collection("profiles").doc(context.read<AuthController>().currentUser.uid).set({'uid':context.read<AuthController>().currentUser.uid,
                                                                  'name':_nameController.text,
                                                                  'occupation':_occupationController.text,
                                                                  'location':_locationController.text,
                                                                  'email':_emailController.text,
                                                                  'phone':_phoneController.text,
                                                                  'img':profileImgPath
        });
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ConferenceProfilesPage(widget._firestore, widget._storage, widget._conference, hasProfile: true,)));
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
            _buildTextField("Full Name", "Your Name", _nameController, _nameValid),
            _buildTextField("Occupation", "Student", _occupationController, _occValid),
            _buildTextField("Location", "Porto, Portugal", _locationController, _locationValid),
            _buildTextField("E-mail", "example@email.com", _emailController, _emailValid),
            _buildTextField("Phone Number", "+351999999999", _phoneController, _phoneValid),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, String placeholder, TextEditingController controller, bool isValid) {
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
          errorText: isValid ? null : "Invalid Information",
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
              image: NetworkImage(profileImg),
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

        var downloadURL = await widget._storage.uploadFile(profileImgPath, file);

        setState(() {
          profileImg = downloadURL!=null ? downloadURL : profileImg ;
          print(profileImg);
        });
      }
      else {
        print('No path Received');
      }
    }
    else {
      print('Grant permission and try again!');
    }
  }
}