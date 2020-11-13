import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:meetix/model/Conference.dart';
import 'package:meetix/model/Profile.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/view/MyWidgets.dart';
import 'package:provider/provider.dart';

class ViewProfileDetailsPage extends StatefulWidget {
  final Conference _conference;
  final Profile _profile;
  final StorageController _storage;
  final bool hasProfile;

  ViewProfileDetailsPage(this._conference, this._profile, this._storage, {this.hasProfile = false});

  @override
  _ViewProfileDetailsPageState createState() {
    return _ViewProfileDetailsPageState();
  }
}

class _ViewProfileDetailsPageState extends State<ViewProfileDetailsPage> {
  bool _liked = false;
  bool _ownProfile = false;

  @override
  void initState() {
    if (widget._profile.uid == context.read<AuthController>().currentUser.uid)
      _ownProfile = true;
    else
      widget._conference.reference.collection("likes").doc(context.read<AuthController>().currentUser.uid).get().then((value) => updateLiked(value.data()['liked'].contains(widget._profile.uid)));
    super.initState();
  }

  void updateLiked(bool val) {
    setState(() {
      _liked = val;
    });
  }

  void likeProfile() {
    if (!widget.hasProfile) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Self-love is important!")));
    } else {
      List<String> like = [widget._profile.uid];
      updateLiked(!_liked);
      if (_liked)
        widget._conference.reference.collection("likes").doc(context
            .read<AuthController>()
            .currentUser
            .uid).set(
            {"liked": FieldValue.arrayUnion(like)}, SetOptions(merge: true));
      else
        widget._conference.reference.collection("likes").doc(context
            .read<AuthController>()
            .currentUser
            .uid).set(
            {"liked": FieldValue.arrayRemove(like)}, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget._profile.name + "'s Profile"),
          centerTitle: true,
      ),

      body: _buildBody(context),

      floatingActionButton: Builder(
        builder: (BuildContext context) {
          return FloatingActionButton.extended(
            onPressed: (widget.hasProfile)? ((!_ownProfile)? likeProfile : (){
              Scaffold.of(context).removeCurrentSnackBar(reason: SnackBarClosedReason.remove);
              Scaffold.of(context).showSnackBar(SnackBar(content: Text("Self-love is important!"),),);
            }) : (){
              Scaffold.of(context).removeCurrentSnackBar(reason: SnackBarClosedReason.remove);
              Scaffold.of(context).showSnackBar(SnackBar(content: Text("You must create a profile first!"),),);
            },
            icon: Icon(Icons.thumb_up_sharp, color: Colors.white,),
            label: (_liked) ? Text("Liked") : Text("Like"),
            backgroundColor: (_ownProfile || !widget.hasProfile) ? Colors.grey :
                             (_liked) ? Colors.green : Colors.blue,
          );
        }
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView(
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
