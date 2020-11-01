import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'view/ConferenceListPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(startApp());
}

class startApp extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Container(
            decoration: BoxDecoration(color: Colors.red),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MeetixApp();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Container(
          decoration: BoxDecoration(color: Colors.deepPurple),
        );
      },
    );
  }
}

class MeetixApp extends StatelessWidget {
  final FirestoreController firestore = FirestoreController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meetix',
      home: ConferenceListPage(firestore),
    );
  }
}

