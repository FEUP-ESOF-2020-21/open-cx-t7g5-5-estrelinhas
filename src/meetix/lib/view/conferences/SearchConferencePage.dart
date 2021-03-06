import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/controller/FunctionsController.dart';
import 'package:meetix/controller/SearchController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/model/Conference.dart';
import 'package:meetix/view/meetix_widgets/MyWidgets.dart';
import 'package:provider/provider.dart';

import 'ConferencePage.dart';
import '../profiles/CreateProfilePage.dart';

class SearchConferencePage extends StatefulWidget {
  final onChangeConfTab;

  SearchConferencePage({this.onChangeConfTab});

  @override
  _SearchConferencePageState createState() => _SearchConferencePageState();
}

class _SearchConferencePageState extends State<SearchConferencePage> {
  var queryConferences = [];

  var _firestore;
  var _storage;
  var _functions;

  @override
  void initState() {
    super.initState();
    _firestore = context.read<FirestoreController>();
    _storage = context.read<StorageController>();
    _functions = context.read<FunctionsController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search conferences"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12,),
            child: TextField(
              style: TextStyle(fontSize: 20,),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search by name or interests",
              ),
              textInputAction: TextInputAction.search,
              autofocus: true,
              onChanged: (value) {
                if (value.isNotEmpty)
                  context.read<SearchController>().searchConferences(value)
                    .then((conferences) => setState((){ queryConferences = conferences; }));
                else
                  setState((){ queryConferences = []; });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: queryConferences.length,
              itemBuilder: (context, idx) {
                // return Text(queryConferences[idx].objectID);
                return _buildConference(context, queryConferences[idx].objectID);
              }),
          ),
        ],
      ),
    );
  }

  Widget _buildConference(BuildContext context, String conference_id) {
    return StreamBuilder<QuerySnapshot>(
        stream: context.watch<FirestoreController>().getConferenceById(conference_id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.size > 0)
              return _buildListItem(context, snapshot.data.docs.first);
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

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final _conference = Conference.fromSnapshot(data);

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => openConference(context, _conference))).then((value) => setState((){}));
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Displays conference icon, if null, displays initial
            CustomAvatar(
              imgURL: _conference.img,
              source: context.watch<StorageController>(),
              initials: _conference.name[0],
            ),
            SizedBox(
              width: 16.0,
            ),
            Text(
              _conference.name,
              style: Theme.of(context).textTheme.headline6,
            ),
            Expanded(child: SizedBox()),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget openConference(BuildContext context, Conference conference) {
    return FutureBuilder(
      future: conference.reference.collection('profiles').where('uid', isEqualTo: context.watch<AuthController>().currentUser.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.size > 0) {
            return ConferencePage(_firestore, _storage,  _functions, conference, hasProfile: true, onChangeConfTab: widget.onChangeConfTab);
          } else {
            return CreateProfilePage(_firestore, _storage, _functions, conference, onChangeConfTab: widget.onChangeConfTab);
          }
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text(snapshot.error.toString()),),);
        } else {
          return Scaffold(body: Center(child: CircularProgressIndicator(),),);
        }
      },
    );
  }
}
