import 'package:flutter/material.dart';
import 'package:meetix/model/Profile.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/view/MyWidgets.dart';
import '../controller/FirestoreController.dart';

class ViewProfileDetailsPage extends StatefulWidget {
  final Profile _profile;
  final StorageController _storage;

  ViewProfileDetailsPage(this._profile, this._storage);

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
        onPressed: (){},
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
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ListView(
          shrinkWrap: true,
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