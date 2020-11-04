import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/view/SignInPage.dart';
import 'view/ConferenceListPage.dart';
import 'package:provider/provider.dart';

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



  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthController>(
            create: (context) => AuthController(),
        ),
        StreamProvider(
            create: (context) => context.read<AuthController>().authStateChanges,
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Meetix',
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final FirestoreController firestore = FirestoreController();
  final StorageController storage = StorageController();
  @override
  Widget build(BuildContext context) {
    final user = context.watch<User>();
    return (user == null)? SignInPage() :  ConferenceListPage(firestore, storage);
  }
}

