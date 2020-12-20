import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/controller/FunctionsController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/model/Conference.dart';
import 'package:meetix/view/conferences/ConferencePage.dart';
import 'package:meetix/view/meetix_widgets/MyWidgets.dart';
import 'package:provider/provider.dart';


class MyJoinedConferencesPage extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;
  final FunctionsController _functions;
  @required final Function(int) onChangeConfTab;

  MyJoinedConferencesPage(this._firestore, this._storage, this._functions,
      {this.onChangeConfTab});

  @override
  _MyJoinedConferencesPageState createState() {
    return _MyJoinedConferencesPageState();
  }
}

class _MyJoinedConferencesPageState extends State<MyJoinedConferencesPage> {
  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    // Gets stream from Firestore with the conference info
    return StreamBuilder<QuerySnapshot>(
      stream: widget._firestore.getMyProfilesFromJoinedConferences(
          context.watch<AuthController>().currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.size > 0) {
            return _buildList(context, snapshot.data.docs);
          } else {
            return Center(child: Text("You have not joined any conference"));
          }
        } else if (snapshot.hasError) {
          return Text("Error :(");
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    List<Widget> conferences = snapshot
        .map((data) =>
            _buildConference(context, data.reference.parent.parent.id))
        .toList();
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: conferences.length,
      separatorBuilder: (context, index) => Divider(
        height: 0,
        color: Colors.grey,
      ),
      itemBuilder: (context, index) => conferences[index],
    );
  }

  Widget _buildConference(BuildContext context, String conference_id) {
    return StreamBuilder<QuerySnapshot>(
        stream: widget._firestore.getConferenceById(conference_id),
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
        Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ConferencePage(widget._firestore,
                        widget._storage, widget._functions, _conference,
                        hasProfile: true,
                        onChangeConfTab: widget.onChangeConfTab)))
            .then((value) => setState(() {}));
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Displays conference icon, if null, displays initial
            CustomAvatar(
              imgURL: _conference.img,
              source: widget._storage,
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
}
