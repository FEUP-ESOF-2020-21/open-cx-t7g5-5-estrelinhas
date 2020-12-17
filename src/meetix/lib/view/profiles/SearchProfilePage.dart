import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/model/Conference.dart';
import 'package:meetix/model/Profile.dart';
import 'package:meetix/view/meetix_widgets/MyWidgets.dart';
import 'package:provider/provider.dart';
import 'package:meetix/controller/SearchController.dart';


class SearchProfilePage extends StatefulWidget {
  final Conference _conference;
  final hasProfile;

  SearchProfilePage(this._conference, this.hasProfile);

  @override
  _SearchProfilePageState createState() => _SearchProfilePageState();
}

class _SearchProfilePageState extends State<SearchProfilePage> {
  var queryResults = [];

  var _firestore;
  var _storage;

  @override
  void initState() {
    super.initState();
    _firestore = context.read<FirestoreController>();
    _storage = context.read<StorageController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search profiles'),),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: TextField(
            style: TextStyle(fontSize: 20,),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "Name, interests, location or occupation",
              hintStyle: TextStyle(fontSize: 16),
            ),
            textInputAction: TextInputAction.search,
            autofocus: true,
            onChanged: (value) {
              if (value.isNotEmpty) {
                context.read<SearchController>().searchProfiles(widget._conference.reference.id, context.read<AuthController>().currentUser.uid, value)
                    .then((profiles) =>
                    setState(() {
                      queryResults = profiles;
                    }));
              }
              else
                setState((){ queryResults = []; });
            },
          ),
        ),
        Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: queryResults.length,
              separatorBuilder: (context, index) => Divider(
                height: 0,
                color: Colors.grey,
              ),
              itemBuilder: (context, idx) {
                return _buildProfile(queryResults[idx].objectID);
              },
            )
        ),
      ],
    );
  }

  Widget _buildProfile(String profileID) {
      return StreamBuilder<QuerySnapshot>(
          stream: context.read<FirestoreController>().getProfileById(widget._conference, profileID),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.size > 0)
                return ProfileListItem(Profile.fromSnapshot(snapshot.data.docs.first), widget._conference, _firestore, _storage, widget.hasProfile);
              else {
                return Center(child: Text("This conference does not exist!"));
              }
            } else if (snapshot.hasError) {
              return Text("Error :(");
            } else {
              return Center(child: CircularProgressIndicator());
            }
          });
  }
}
