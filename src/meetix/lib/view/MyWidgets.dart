import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/model/Conference.dart';
import 'package:meetix/model/Profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:meetix/controller/AuthController.dart';

import 'ViewProfileDetailsPage.dart';


class CustomAvatar extends StatelessWidget {
  @required final String imgURL;
  @required final StorageController source;
  String initials;
  double radius;

  CustomAvatar({this.imgURL, this.source, this.initials = '', this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return (imgURL != null)?
    FutureBuilder(
      future: source.getImgURL(imgURL),
      builder: (context, url) {
        if (url.hasError) {
          return CircleAvatar(backgroundImage: NetworkImage("https://www.lewesac.co.uk/wp-content/uploads/2017/12/default-avatar.jpg"), radius: radius);
        } else if (url.hasData) {
          return CircleAvatar(backgroundImage: NetworkImage(url.data), radius: radius);
        } else {
          return SizedBox(width: radius*2, height: radius*2, child: CircularProgressIndicator());
        }
      },
    ) :
    CircleAvatar(
      child: Text(this.initials, style: TextStyle(fontSize: radius),),
      backgroundColor: Theme.of(context).primaryColorLight,
      radius: radius,
    );
  }
}

class ProfileOccupationDisplay extends StatelessWidget {
  @required final Profile profile;

  ProfileOccupationDisplay({this.profile});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(profile.name, style: Theme.of(context).textTheme.headline6,),
            if (profile.occupation != null) ...[
              SizedBox(height: 8.0,),
              Text(profile.occupation),
            ],
          ],
        ),
      ),
    );
  }
}

class AvatarWithBorder extends StatelessWidget {
  ImageProvider<Object> imageProvider;
  double radius, border;
  Icon icon;
  Color borderColor, backgroundColor;

  AvatarWithBorder({this.imageProvider, this.radius = 20, this.border = 5, this.icon, this.backgroundColor, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              spreadRadius: 2,
              blurRadius: 10,
              color: Colors.black.withOpacity(0.1),
              offset: Offset(0, 10)
          ),
        ],
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        backgroundColor: this.borderColor,
        radius: this.radius,
        child: (this.imageProvider != null) ? CircleAvatar(
          backgroundImage: this.imageProvider,
          radius: this.radius - this.border,
        ) : CircleAvatar(
          radius: this.radius - this.border,
          backgroundColor: this.backgroundColor,
          child: (this.icon != null)? this.icon : Icon(Icons.error),
        ),
      )
    );
  }
}

class AvatarWithBorderURL extends StatelessWidget {
  @required String imgURL;
  @required StorageController source;
  double radius, border;
  Color borderColor;

  AvatarWithBorderURL({this.imgURL, this.radius = 20, this.border = 5, this.borderColor, this.source});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              spreadRadius: 2,
              blurRadius: 10,
              color: Colors.black.withOpacity(0.1),
              offset: Offset(0, 10)
          ),
        ],
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        backgroundColor: this.borderColor,
        radius: this.radius,
        child: CustomAvatar(
          imgURL: this.imgURL,
          radius: this.radius - this.border,
          source: this.source,
        ),
      ),
    );
  }
}

// with love, from https://stackoverflow.com/questions/58499358/alert-box-with-multi-select-chip-in-flutter
class MultiSelectChip extends StatefulWidget {
  final List<String> list;
  final Function(List<String>) onSelectionChanged;
  final Function onInvalidSelection;
  final Function(List<String>) isValidSelection;
  final List<String> startSelection;

  MultiSelectChip(this.list, {this.onSelectionChanged, this.onInvalidSelection, this.isValidSelection, this.startSelection});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<String> selectedChoices;

  initState() {
    super.initState();
    selectedChoices = widget.startSelection;
    widget.onSelectionChanged(selectedChoices);
  }

  _buildChoiceList() {
    List<Widget> choices = List();

    widget.list.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Text(item),
          selected: selectedChoices.contains(item),
          onSelected: (selected) {
            setState(() {
              if (!widget.isValidSelection(selectedChoices) && !selectedChoices.contains(item)) {
                widget.onInvalidSelection();
              } else {
                selectedChoices.contains(item) ?
                  selectedChoices.remove(item)
                    :
                  selectedChoices.add(item);
                widget.onSelectionChanged(selectedChoices);
              }
            });
          },
        ),
      ));
    });

    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return Wrap(
          children: _buildChoiceList(),
        );
      },
    );
  }
}

class InterestsWrap extends StatelessWidget{
  @required final List<String> interests;

  InterestsWrap(this.interests);

  @override
  Widget build(BuildContext context) {
    List<Widget> chips = List();
    if(interests != null) {
      interests.forEach((element) {
        chips.add(Container(
          padding: const EdgeInsets.all(2.0),
          child: Chip(
            label: Text(element),
          ),
        ));
      });
    }
    return Wrap(children: chips);
  }
}

class TextFieldWidget extends StatefulWidget{
  @required final String labelText;
  @required final String hintText;
  @required final TextEditingController controller;
  final bool isValid;
  final bool obscure;
  final FontWeight hintWeight;
  final TextInputType textInputType;
  final String defaultValue;
  final String errorText;

  TextFieldWidget({this.labelText, this.hintText, this.hintWeight=FontWeight.w100, this.controller, this.isValid=true, this.textInputType=TextInputType.text, this.defaultValue="", this.errorText="Invalid information", this.obscure=false});

  @override
  _TextFieldState createState() => _TextFieldState();
}

class _TextFieldState extends State<TextFieldWidget>{
  FontWeight weight;

  @override
  void initState() {
    super.initState();
    if (widget.defaultValue != "")
      widget.controller.text = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0, left: 10.0, right: 10.0),
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.textInputType,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.black
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: widget.labelText,
          labelStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontSize: 18,
            fontWeight: widget.hintWeight,
            color: Colors.black,
          ),
          errorText: widget.isValid ? null : widget.errorText,
        ),
        obscureText: widget.obscure,
      ),
    );
  }
}

class SelectInterests extends StatefulWidget{
  @required final Conference conference;
  @required List<String> selectedInterests;
  @required final Function(List<String>) onInterestsChanged;

  SelectInterests({this.conference, this.selectedInterests, this.onInterestsChanged});

  @override
  _SelectInterestsState createState() => _SelectInterestsState();
}

class _SelectInterestsState extends State<SelectInterests> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if(widget.selectedInterests.isNotEmpty) InterestsWrap(widget.selectedInterests),
          OutlineButton(
            highlightedBorderColor: Color.fromRGBO(255, 153, 102, 1),
            child: Text("Select Interests"),
            onPressed: () {FocusScope.of(context).unfocus(); _showInterestsDialog(widget.conference.interests);},
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
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Builder(
            builder: (context) => AlertDialog(
                  title: Text("Interests"),
                  content: MultiSelectChip(
                    interests,
                    onSelectionChanged: (selectedList) {
                      _currentSelection = selectedList;
                    },
                    onInvalidSelection: () {
                      Scaffold.of(context).removeCurrentSnackBar(reason: SnackBarClosedReason.remove);
                      Scaffold.of(context).showSnackBar(SnackBar(content: Text("You can select only up to 5 interests!"), behavior: SnackBarBehavior.floating,),);
                    },
                    isValidSelection: (selectedList) {
                      return selectedList.length < 5;
                    },
                    startSelection: widget.selectedInterests.toList(),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Submit", style: TextStyle(color: Color.fromRGBO(255, 153, 102, 1))),
                      onPressed: () {
                        setState(() {
                          widget.selectedInterests = _currentSelection;
                          widget.onInterestsChanged(widget.selectedInterests);
                        });
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
          ),
        );
          }
        );
  }
}

class ShowAvatarEdit extends StatefulWidget{
  @required final StorageController storage;
  String profileImgUrl;
  @required final Function(File) onFileChosen;

  ShowAvatarEdit({this.storage, this.profileImgUrl='default-avatar.jpg', this.onFileChosen});

  @override
  _ShowAvatarEditState createState() => _ShowAvatarEditState();
}

class _ShowAvatarEditState extends State<ShowAvatarEdit>{
  File profileImg;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {chooseImage();},
      child: Center(
        child: Stack(
          children: [
            if(profileImg != null) (
              AvatarWithBorder(
                radius: 65,
                imageProvider: new FileImage(profileImg),
                  borderColor: Theme.of(context).scaffoldBackgroundColor
              )
            )
            else(
              AvatarWithBorderURL(
                radius: 65,
                imgURL: widget.profileImgUrl,
                source: widget.storage,
                borderColor: Color.fromRGBO(255, 153, 102, 1),
              )
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: AvatarWithBorder(
                border: 4,
                icon: Icon(Icons.edit, color: Colors.white),
                borderColor: Color.fromRGBO(255, 153, 102, 1),
                backgroundColor: Color.fromRGBO(255, 153, 102, 1),
              ),
            ),
          ],
        ) /*CircleAvatar(backgroundImage: new FileImage(widget.profileImg), radius: 65)*/,
      ),
    );
  }

  chooseImage() async {
    final _picker = ImagePicker();
    PickedFile image;

    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;

    if(permissionStatus.isGranted){
      image = await _picker.getImage(source: ImageSource.gallery, imageQuality:70, maxWidth: 400, maxHeight: 400);
      if(image != null){
        File file = File(image.path);

        widget.onFileChosen(file);

        setState(() {profileImg = file;});
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

class ProfileListView extends StatelessWidget {
  final FirestoreController _firestore;
  final StorageController _storage;
  final Conference _conference;
  final bool hasProfile;
  final List<QueryDocumentSnapshot> snapshots;
  @required final bool fromQuery;

  ProfileListView(this._firestore, this._storage, this._conference, this.hasProfile, this.snapshots, {this.fromQuery});

  @override
  Widget build(BuildContext context) {
    return _buildList(context, snapshots);
  }

  Widget _buildList(BuildContext context, List<QueryDocumentSnapshot> snapshot) {
    List<Widget> profiles = snapshot.map((data) {
      if (fromQuery)
        return _buildProfile(context, data);
      else if (context.watch<AuthController>().currentUser.uid != data.data()['uid'])
        return _buildListItem(context, data);
    }).toList();
    profiles.removeWhere((element) => element == null);
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: profiles.length,
      separatorBuilder: (context, index) => Divider(
        height: 0,
        color: Colors.grey,
      ),
      itemBuilder: (context, index) => profiles[index],
    );
  }

  Widget _buildProfile(BuildContext context, DocumentSnapshot data) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.getProfileById(_conference, data.data()['profile_id']),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.size > 0)
            return _buildListItem(context, snapshot.data.docs.first);
          else {
            return Center(child: Text("This profile does not exist!"));
          }
        } else if (snapshot.hasError) {
          return Text("Error :(");
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final profile = Profile.fromSnapshot(data);

    return ProfileListItem(profile, _conference, _firestore, _storage, hasProfile);
  }
}

class ProfileListItem extends StatelessWidget {
  final profile;
  final _conference;
  final _firestore;
  final _storage;
  final hasProfile;

  ProfileListItem(this.profile, this._conference, this._firestore, this._storage, this.hasProfile);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewProfileDetailsPage(
                  _conference,
                  profile.uid,
                  _firestore,
                  _storage,
                  hasProfile: hasProfile,
                )));
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CustomAvatar(
              imgURL: profile.img,
              source: _storage,
              initials: profile.name[0],
              radius: 60,
            ),
            SizedBox(
              width: 20.0,
            ),
            ProfileOccupationDisplay(
              profile: profile,
            ),
            SizedBox(
              width: 20.0,
            ),
            Icon(
              Icons.connect_without_contact_rounded,
              color: Colors.grey,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }
}


class DeleteAccountDialog extends StatefulWidget {
  @override
  _DeleteAccountDialogState createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final TextEditingController _passwordController = new TextEditingController();
  bool _passwordValid = true;

  updateValid(cond) {
    setState(() {
      _passwordValid = cond;
    });
  }

  deleteAccount() async {
    updateValid(_passwordController.text.isNotEmpty);
    if (_passwordValid) {
      String code = await context.read<AuthController>().deleteAccount(
          password: _passwordController.text);
      if (code == 'wrong-password')
        updateValid(false);
      if (code == 'success')
        Navigator.popUntil(context, ModalRoute.withName('/'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Delete account"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Are you sure you want to delete your account?'),
          SizedBox(height: 20,),
          Text('This will also delete all profiles and conferences that you have created.', style: TextStyle(fontWeight: FontWeight.bold),),
          SizedBox(height: 20,),
          Text('This action cannot be undone!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),),
          TextField(
            controller: _passwordController,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              labelText: "Insert your password",
              errorText: (_passwordValid)? null : "Wrong password!",
            ),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        FlatButton(
          textColor: Colors.grey,
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Color.fromRGBO(255, 153, 102, 1),)),
        ),
        FlatButton(
          onPressed: deleteAccount,
          child: Text('Delete', style: TextStyle(color: Color.fromRGBO(255, 153, 102, 1),)),
        )
      ],
    );
  }
}





