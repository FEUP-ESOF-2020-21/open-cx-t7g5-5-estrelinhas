import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/model/Conference.dart';
import 'package:meetix/model/Profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:meetix/controller/AuthController.dart';


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
  String imgURL;
  double radius, border;
  Icon icon;
  Color borderColor, backgroundColor;
  StorageController source;

  AvatarWithBorder({this.imgURL, this.radius = 20, this.border = 5, this.icon, this.backgroundColor, this.borderColor, this.source});

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
        child: (this.imgURL != null && this.source != null)? CustomAvatar(
            imgURL: this.imgURL,
            radius: this.radius - this.border,
            source: this.source,
        ) : CircleAvatar(
          radius: this.radius - this.border,
          backgroundColor: this.backgroundColor,
          child: (this.icon != null)? this.icon : Icon(Icons.error),
        ),
      ),
    );
  }
}

// with love, from https://stackoverflow.com/questions/58499358/alert-box-with-multi-select-chip-in-flutter
class MultiSelectChip extends StatefulWidget {
  final List<String> list;
  final Function(List<String>) onSelectionChanged;

  MultiSelectChip(this.list, {this.onSelectionChanged});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<String> selectedChoices = List();

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
              selectedChoices.contains(item)
                  ? selectedChoices.remove(item)
                  : selectedChoices.add(item);
              widget.onSelectionChanged(selectedChoices);
            });
          },
        ),
      ));
    });

    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
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
  final FontWeight hintWeight;
  final TextInputType textInputType;

  TextFieldWidget({this.labelText, this.hintText, this.hintWeight=FontWeight.w100, this.controller, this.isValid=true, this.textInputType=TextInputType.text});

  @override
  _TextFieldState createState() => _TextFieldState();
}

class _TextFieldState extends State<TextFieldWidget>{
  FontWeight weight;
  @override
  Widget build(BuildContext context) {
    /*if(widget.hint) weight=FontWeight.w100;
    else  weight=FontWeight.w400;*/
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
          errorText: widget.isValid ? null : "Invalid Information",
        ),
      ),
    );
  }
}

class SelectInterests extends StatefulWidget{
  @required final Conference conference;
  @required List<String> selectedInterests;
  @required bool hasInterests;
  @required final Function(List<String>) onInterestsChanged;

  SelectInterests({this.conference, this.selectedInterests, this.hasInterests, this.onInterestsChanged});

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
          if(widget.selectedInterests.isNotEmpty) InterestsWrap(widget.selectedInterests)
          else
            if(!widget.hasInterests)
              Text(
                "No interests selected!",
                style: TextStyle(color: Colors.red),
              ),
          RaisedButton(
            child: Text("Select Interests"),
            onPressed: () => _showInterestsDialog(widget.conference.interests),
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
                  widget.selectedInterests = _currentSelection;
                  widget.onInterestsChanged(widget.selectedInterests);
                  (widget.selectedInterests.isEmpty)? widget.hasInterests = false : widget.hasInterests = true;
                });
                Navigator.of(context).pop();
              },
            )
          ],
        );
      });
  }
}

class ShowAvatarEdit extends StatefulWidget{
  @required final StorageController storage;
  @required final Conference conference;
  String profileImgPath;
  @required final Function(String) onPathChanged;

  ShowAvatarEdit({this.storage, this.conference, this.profileImgPath='default-avatar.jpg', this.onPathChanged});

  @override
  _ShowAvatarEditState createState() => _ShowAvatarEditState();


}

class _ShowAvatarEditState extends State<ShowAvatarEdit>{
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {uploadImage();},
      child: Center(
        child: Stack(
          children: [
            AvatarWithBorder(
              radius: 65,
              imgURL: widget.profileImgPath,
              source: widget.storage,
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
        widget.profileImgPath = 'conferences/' + widget.conference.reference.id + '/profiles/' + context.read<AuthController>().currentUser.uid + '/profile_img';
        widget.onPathChanged(widget.profileImgPath);

        var file = File(image.path);

        await widget.storage.uploadFile(widget.profileImgPath, file);

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
}
