import 'package:flutter/material.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/model/Conference.dart';
import 'package:meetix/model/Profile.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/view/EditProfilePage.dart';
import 'package:meetix/view/MyWidgets.dart';
import 'package:provider/provider.dart';

class ViewProfileDetailsPage extends StatefulWidget {
  final Conference _conference;
  final Profile _profile;
  final StorageController _storage;
  final FirestoreController _firestore;
  final bool hasProfile;

  ViewProfileDetailsPage(this._conference, this._profile, this._firestore, this._storage, {this.hasProfile = false});

  @override
  _ViewProfileDetailsPageState createState() {
    return _ViewProfileDetailsPageState();
  }
}

class _ViewProfileDetailsPageState extends State<ViewProfileDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget._profile.name + "'s Profile"),
          centerTitle: true,
      ),

      body: _buildBody(context),

      floatingActionButton: LikeEditButton(widget._conference, widget._profile, widget._firestore, widget._storage, hasProfile: widget.hasProfile,),
    );
  }

  Widget _buildBody(BuildContext context) {
    return
      ListView(
          children: <Widget>[
            SizedBox(height:10.0),
            _buildAva(context),
            if (widget._profile.occupation != null) ...[
              _buildInfo(context, "Occupation", widget._profile.occupation),
            ],
            if (widget._profile.location != null) ...[
              _buildInfo(context, "Location", widget._profile.location),
            ],
            if (widget._profile.email != null) ...[
              _buildInfo(context, "E-mail", widget._profile.email),
            ],
            if (widget._profile.phone != null) ...[
              _buildInfo(context, "Phone number", widget._profile.phone),
            ],
            if (widget._profile.interests != null) ...[
              _buildInterests(context, widget._profile.interests),
            ],
            SizedBox(height:20.0),
    ]
      );
  }

  Widget _buildInfo(BuildContext context, String labelText, String infoText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            SizedBox(height:50.0),
            Text(labelText,
              style: Theme.of(context).textTheme.overline,
              textScaleFactor: 1.5,
            ),
            Text(infoText,
              style: Theme.of(context).textTheme.bodyText1,
              textScaleFactor: 1.8,
            ),
          ]
      ),
    );
  }

  Widget _buildInterests(BuildContext context, List<String> interests){
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            SizedBox(height:50.0),
            Text("Interests",
              style: Theme.of(context).textTheme.overline,
              textScaleFactor: 1.5,
            ),
            InterestsWrap(interests),
          ]
      ),
    );
  }

  Widget _buildAva(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 10.0, right:10.0),
      child: Center(
          child:Column(
            children:[
              CustomAvatar(
                imgURL: widget._profile.img,
                source: widget._storage,
                initials: widget._profile.name[0],
                radius: 60,
              ),
              SizedBox(height: 20.0),
              Text(widget._profile.name,
                style: Theme.of(context).textTheme.headline5,
                textScaleFactor: 1.5,
                textAlign: TextAlign.center,
              ),
            ],
          )
      ),
    );
  }
}

class LikeEditButton extends StatefulWidget {
  final Conference _conference;
  final Profile _profile;
  final StorageController _storage;
  final FirestoreController _firestore;
  final bool hasProfile;

  LikeEditButton(this._conference, this._profile, this._firestore, this._storage, {this.hasProfile = false});

  @override
  _LikeEditButtonState createState() => _LikeEditButtonState();
}

class _LikeEditButtonState extends State<LikeEditButton> {
  bool _liked = false;
  bool _ownProfile = false;
  bool _match = false;

  @override
  Widget build(BuildContext context) {
    return (_ownProfile)? _editButton() : _likeButton();
  }

  @override
  void initState() {
    if (widget._profile.uid == context.read<AuthController>().currentUser.uid)
      _ownProfile = true;
    else {
      widget._firestore.checkLike(widget._conference, context.read<AuthController>().currentUser.uid, widget._profile.uid, onLike: _onLike);
      widget._firestore.checkMatch(widget._conference, context.read<AuthController>().currentUser.uid, widget._profile.uid, onMatch: _onExistingMatch);
    }
    super.initState();
  }

  void _updateLikedState(bool val) {
    setState(() {
      _liked = val;
    });
  }

  void _updateMatchState(bool val) {
    setState(() {
      _match = val;
    });
  }

  void _onLike() {
    _updateLikedState(true);
  }

  void _onExistingMatch() {
    _updateMatchState(true);
  }

  void _onNewMatch() {
    _updateMatchState(true);
    _newMatchSnackBar();
    widget._firestore.addMatch(widget._conference, context.read<AuthController>().currentUser.uid, widget._profile.uid);
  }

  void _likeProfile() {
    _updateLikedState(!_liked);
    if (_liked) {
      widget._firestore.addLike(widget._conference, context.read<AuthController>().currentUser.uid, widget._profile.uid);
      widget._firestore.checkMatch(widget._conference, context.read<AuthController>().currentUser.uid, widget._profile.uid, onMatch: _onNewMatch);
    }
    else {
      widget._firestore.removeLike(widget._conference, context.read<AuthController>().currentUser.uid, widget._profile.uid);
      if (_match) {
        _updateMatchState(false);
        widget._firestore.removeMatch(widget._conference, context.read<AuthController>().currentUser.uid, widget._profile.uid);
      }
    }
  }

  void _noProfileSnackBar() {
    Scaffold.of(context).removeCurrentSnackBar(reason: SnackBarClosedReason.remove);
    Scaffold.of(context).showSnackBar(SnackBar(content: Text("You must create a profile first!"),),);
  }
  
  void _newMatchSnackBar() {
    Scaffold.of(context).removeCurrentSnackBar(reason: SnackBarClosedReason.remove);
    Scaffold.of(context).showSnackBar(SnackBar(content: Text("It's a match!"),),);
  }

  Widget _likeButton() {
    return FloatingActionButton.extended(
      onPressed: (widget.hasProfile)? _likeProfile : _noProfileSnackBar,
      icon: (_match)? Icon(Icons.emoji_people) : Icon(Icons.thumb_up_sharp),
      label: (_liked) ? ((_match)? Text("Match") : Text("Liked")) : Text("Like"),
      backgroundColor: (!widget.hasProfile) ? Colors.grey :
      (_liked) ? (_match)? Colors.pink : Colors.green : Colors.blue,
    );
  }

  Widget _editButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage(widget._firestore, widget._storage, widget._conference, widget._profile)));
      },
      icon: Icon(Icons.edit, color: Colors.white,),
      label: Text("Edit"),
      backgroundColor: Colors.purple,
    );
  }
}
