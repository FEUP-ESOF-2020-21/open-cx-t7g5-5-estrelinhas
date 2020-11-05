import 'package:flutter/material.dart';
import 'package:meetix/model/Profile.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/view/MyWidgets.dart';
import '../controller/FirestoreController.dart';

class PeopleProfilePage extends StatefulWidget {
  final Profile _profile;
  final StorageController _storage;

  PeopleProfilePage(this._profile, this._storage);

  @override
  _PeopleProfilePageState createState() {
    return _PeopleProfilePageState();
  }
}

class _PeopleProfilePageState extends State<PeopleProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget._profile.name + " Profile"),
          centerTitle: true,
          backgroundColor: Colors.blue,
          elevation: 2 ,
          actions: [
            IconButton(
                icon:Icon(
                  Icons.cancel_outlined,
                  size: 30,
                  color:Colors.white,
                ),
                onPressed:(){Navigator.pop(context);}//atençao isto tem que ser mudado
            )
          ]
      ),

      body: _buildBody(context),

      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.thumb_up_sharp, color: Colors.white,),
        label: Text("Like"),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return
      ListView(
          children: <Widget>[
            SizedBox(height:10.0),
            _buildAva(context),
            _buildInfo(context, "Occupation", widget._profile.occupation),
            _buildInfo(context, "Location", widget._profile.location),
            _buildInfo(context, "E-mail", widget._profile.email),
            _buildInfo(context, "Phone number", widget._profile.phone),
          ]
      );
  }

  Widget _buildInfo(BuildContext context, String labelText, String infoText) {
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ListView(
          shrinkWrap: true,
          children:[
            SizedBox(height:50.0),
            Text(labelText,
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(infoText,
              style: Theme.of(context).textTheme.bodyText1,
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
                  style:TextStyle(color:Colors.grey)
              ),
            ],
          )
      ),
    );
  }
}