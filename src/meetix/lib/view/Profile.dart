import 'package:flutter/material.dart';
import 'package:meetix/controller/StorageController.dart';
import '../controller/FirestoreController.dart';

class Profile extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;

  Profile(this._firestore, this._storage);

  @override
  _ProfileState createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Meetix '),
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
              onPressed:(){
                Navigator.pop(context);//atençao isto tem que ser mudado
              }
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
   /* // Gets stream from Firestore with the conference info
    return StreamBuilder<QuerySnapshot>(
      stream: widget._firestore.getConferences(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildAva(context, snapshot.data.docs);
      },
    );*/
    return
          Column(
            children: <Widget>[
              SizedBox(height:10.0),
              _buildAva(context),
              _buildInfoList(context),
            ]
          );

  }

  Widget _buildInfoList(BuildContext context) {
    return  Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: ListView(
            shrinkWrap: true,
            children:[
              SizedBox(height:50.0),
              Text("Ocupation",
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height:40.0),
              Text("Location",
                style: Theme.of(context).textTheme.headline6,
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
              CircleAvatar(
                radius: 65,
                //image: NetworkImage("https://www.lewesac.co.uk/wp-content/uploads/2017/12/default-avatar.jpg"),
                backgroundColor: Colors.blue,
              ),
              SizedBox(height: 20.0),
              Text("JOANA SILVA",
                style:TextStyle(color:Colors.grey)
              ),
            ],
          )
        ),
    );
  }

}