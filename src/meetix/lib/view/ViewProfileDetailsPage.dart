import 'package:cloud_firestore/cloud_firestore.dart';
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
  final String _profileID;
  final StorageController _storage;
  final FirestoreController _firestore;
  final bool hasProfile;

  ViewProfileDetailsPage(this._conference, this._profileID, this._firestore, this._storage, {this.hasProfile = false});

  @override
  _ViewProfileDetailsPageState createState() {
    return _ViewProfileDetailsPageState();
  }
}

class _ViewProfileDetailsPageState extends State<ViewProfileDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return getProfile(context);
  }

  Widget getProfile(BuildContext context) {
    return StreamBuilder(
      stream: widget._firestore.getProfileById(widget._conference, widget._profileID),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.size > 0)
            return _showProfile(context, snapshot.data.docs.first);
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

  Widget _showProfile(BuildContext context, DocumentSnapshot data) {
    Profile profile = Profile.fromSnapshot(data);

    return Scaffold(
      appBar: AppBar(
        title: Text(profile.name + "'s Profile"),
        centerTitle: true,
      ),

      body: _buildBody(context, profile),

      floatingActionButton: LikeEditButton(widget._conference, profile, widget._firestore, widget._storage, hasProfile: widget.hasProfile, onSetState: (){setState(() {});},),
    );
  }

  Widget _buildBody(BuildContext context, Profile profile) {
    return
      ListView(
          children: <Widget>[
            SizedBox(height:10.0),
            _buildAva(context, profile),
            if (profile.occupation != null) ...[
              _buildInfo(context, "Occupation", profile.occupation),
            ],
            if (profile.location != null) ...[
              _buildInfo(context, "Location", profile.location),
            ],
            if (profile.email != null) ...[
              _buildInfo(context, "E-mail", profile.email),
            ],
            if (profile.phone != null) ...[
              _buildInfo(context, "Phone number", profile.phone),
            ],
            if (profile.interests != null) ...[
              _buildInterests(context, profile.interests),
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

  Widget _buildAva(BuildContext context, Profile profile){
    return Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 10.0, right:10.0),
        child: Center(
          child:Column(
            children:[
              CustomAvatar(
                imgURL: profile.img,
                source: widget._storage,
                initials: profile.name[0],
                radius: 60,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name,
                      style: Theme.of(context).textTheme.headline5,
                      textScaleFactor: 1.5,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if(profile.uid == widget._conference.uid)
                Container(
                  alignment: Alignment.bottomCenter,
                  height:20.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:<Widget>[
                      Text('Staff', style:TextStyle(
                          fontWeight:FontWeight.bold,
                          fontSize:20.0
                      ),),
                      SizedBox(width:5.0),
                      Icon(Icons.support_agent_sharp, color:Colors.blue)
                    ],
                  ),
                ),
              if(profile.uid == widget._conference.uid && profile.uid == context.watch<AuthController>().currentUser.uid)
                SizedBox(height: 10),
              if (profile.uid == context.watch<AuthController>().currentUser.uid)
                Container(
                  alignment: Alignment.bottomCenter,
                  height:20.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:<Widget>[
                      Text('You', style:TextStyle(
                          fontWeight:FontWeight.bold,
                          fontSize:20.0
                      ),),
                      SizedBox(width:5.0),
                      Icon(Icons.person, color:Colors.pink)
                    ],
                  ),
                ),
            ],
          ),

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
  final Function onSetState;

  LikeEditButton(this._conference, this._profile, this._firestore, this._storage, {this.hasProfile = false, this.onSetState});

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
      widget._firestore.checkLikeMatch(widget._conference, context.read<AuthController>().currentUser.uid, widget._profile.uid, onLike: _onLike, onMatch: _onExistingMatch);
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
  }

  void _likeProfile() {
    _updateLikedState(!_liked);
    if (_liked) {
      widget._firestore.addLike(widget._conference, context.read<AuthController>().currentUser.uid, widget._profile.uid);
      widget._firestore.checkMatchTransaction(widget._conference, context.read<AuthController>().currentUser.uid, widget._profile.uid, onMatch: _onNewMatch);
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
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditProfilePage(widget._firestore, widget._storage, widget._conference, widget._profile))
        ).then((value) => setState(() { widget.onSetState(); }));
      },
      icon: Icon(Icons.edit, color: Colors.white,),
      label: Text("Edit"),
      backgroundColor: Colors.purple,
    );
  }
}
