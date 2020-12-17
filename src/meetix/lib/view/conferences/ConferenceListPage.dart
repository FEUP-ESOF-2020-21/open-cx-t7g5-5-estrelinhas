import 'package:flutter/material.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/controller/FunctionsController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/view/conferences/ActiveConferencesPage.dart';
import 'package:meetix/view/conferences/CreateConferencePage.dart';
import 'package:meetix/view/conferences/MyJoinedConferencesPage.dart';
import 'package:meetix/view/conferences/SearchConferencePage.dart';
import 'package:provider/provider.dart';
import 'package:meetix/view/auth/EditAccountPage.dart';
import 'MyCreatedConferencesPage.dart';

class ConferenceListPage extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;
  final FunctionsController _functions;

  ConferenceListPage(this._firestore, this._storage, this._functions): super(key: Key("ConferenceListPage"));

  @override
  _ConferenceListPageState createState() {
    return _ConferenceListPageState();
  }
}

class _ConferenceListPageState extends State<ConferenceListPage> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _AppTitle(context)),
      body: _buildBody(context),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 150,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 153, 102, 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Meetix",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Text(
                      (context.watch<AuthController>().currentUser.displayName == null)? "Welcome!" : "Welcome " + context.watch<AuthController>().currentUser.displayName + "!",
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white
                      ),
                    ),
                    SizedBox(height: 8,)
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text("Create Conference"),
              onTap: (){
                Navigator.pop(context);
                changeCurrentTab(2);
                Navigator.push(context, MaterialPageRoute(builder: (context) => CreateConferencePage(widget._firestore, widget._storage, widget._functions)));
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text("Available Conferences"),
              onTap: (){
                Navigator.pop(context); /* Close drawer */
                changeCurrentTab(0);
              }
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text("Joined Conferences"),
              onTap: (){
                Navigator.pop(context); /* Close drawer */
                changeCurrentTab(1);
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text("Created Conferences"),
              onTap: (){
                Navigator.pop(context); /* Close drawer */
                changeCurrentTab(2);
              },
            ),
            Divider(
              color: Color.fromRGBO(255, 153, 102, 1),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.0, 10.0, 10.0, 10.0),
              child: Text("Settings", style: TextStyle(color: Color.fromRGBO(255, 153, 102, 1),),),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Account settings"),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditAccountPage(widget._firestore, widget._storage, widget._functions))).then((value) => setState((){}));
                },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              key: Key("logoutButton"),
              onTap: (){ context.read<AuthController>().signOut(); },
            ),
          ],
        ),
      ),
      floatingActionButton:
        (_currentTab == 0)? FloatingActionButton(
          backgroundColor: Colors.orange,
          child: Icon(Icons.search),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SearchConferencePage(onChangeConfTab: changeCurrentTab)));
          },
        ) : null,
    );
  }

  Widget _buildBody(BuildContext context) {
    return IndexedStack(
      index: _currentTab,
      children: [
        ActiveConferencesPage(widget._firestore, widget._storage, widget._functions, onChangeConfTab: changeCurrentTab),
        MyJoinedConferencesPage(widget._firestore, widget._storage, widget._functions, onChangeConfTab: changeCurrentTab),
        MyCreatedConferencesPage(widget._firestore, widget._storage, widget._functions, onChangeConfTab: changeCurrentTab)
      ],
    );
  }

  Widget _AppTitle(BuildContext context) {
    return IndexedStack(
      index: _currentTab,
      children: [
        Text("Available Conferences"),
        Text("Joined Conferences"),
        Text("Created Conferences"),
      ],
    );
  }

  changeCurrentTab(int tab){
    setState(() {
      _currentTab = tab;
    });
  }
}
