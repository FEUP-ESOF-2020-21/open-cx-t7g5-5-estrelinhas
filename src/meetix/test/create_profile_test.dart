import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/controller/FunctionsController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/model/Conference.dart';
import 'package:meetix/model/Profile.dart';
import 'package:meetix/view/ConferencePage.dart';
import 'package:meetix/view/CreateProfilePage.dart';
import 'package:meetix/view/ViewProfileDetailsPage.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockFirestore extends Mock implements FirestoreController {}
class MockQSnapshot extends Mock implements QuerySnapshot {}
class MockQDSnapshot extends Mock implements QueryDocumentSnapshot {}
class MockDRef extends Mock implements DocumentReference {}

class MockStorage extends Mock implements StorageController {}

class MockFunctions extends Mock implements FunctionsController {}

class MockAuth extends Mock implements AuthController {}
class MockUser extends Mock implements User {}

class MockConference extends Mock implements Conference {}
class MockProfile extends Mock implements Profile {}

class PageWrapper extends StatelessWidget {
  final page;
  final auth = MockAuth();
  final user = MockUser();

  PageWrapper(this.page);

  @override
  Widget build(BuildContext context) {
    when(auth.currentUser).thenReturn(user);
    when(user.uid).thenReturn("user");

    return MultiProvider(
      providers: [
        Provider<AuthController>(
          create: (context) => auth,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Meetix',
        home: this.page,
      ),
    );
  }
}


void main() {
  group('Profile List and Displaying Tests', () {
    var firestore = MockFirestore();
    var qsnap = MockQSnapshot();
    var dref = MockDRef();
    var qdsnap = MockQDSnapshot();

    var storage = MockStorage();

    var functions = MockFunctions();

    var conference = MockConference();
    var profile1 = MockProfile();
    var profile2 = MockProfile();
    var profile3 = MockProfile();
    var profiles_qsnap = MockQSnapshot();
    var profiles_qsnap_2 = MockQSnapshot();
    var profile1_qdsnap = MockQDSnapshot();
    var profile2_qdsnap = MockQDSnapshot();
    var profile3_qdsnap = MockQDSnapshot();
    var profile4_qdsnap = MockQDSnapshot();

    when(conference.name).thenAnswer((_) => "Mockference");
    when(conference.uid).thenReturn("user");

    when(profile1.name).thenReturn("Adam");
    when(profile1.uid).thenReturn("1");
    when(profile2.name).thenReturn("Eve");
    when(profile2.uid).thenReturn("2");
    when(profile3.name).thenReturn("Steve");
    when(profile3.uid).thenReturn("3");

    when(conference.reference).thenReturn(dref);
    when(dref.id).thenReturn("1");
    when(qsnap.size).thenReturn(1);
    when(qsnap.docs).thenReturn([qdsnap]);
    when(qdsnap.data()).thenReturn({'name':"Mockference", 'start_date':Timestamp(1607878030, 0), 'end_date':Timestamp(1607888030, 0)});
    when(qdsnap.reference).thenReturn(dref);

    when(firestore.getConferenceById("1")).thenAnswer((_) {
      return Stream<MockQSnapshot>.value(qsnap);
    });

    when(firestore.getConferenceProfiles(any)).thenAnswer((_) {
      return Stream<MockQSnapshot>.fromIterable([profiles_qsnap, profiles_qsnap_2]);
    });
    when(profiles_qsnap.size).thenReturn(3);
    when(profiles_qsnap.docs).thenReturn([profile1_qdsnap, profile2_qdsnap, profile3_qdsnap]);
    when(profiles_qsnap_2.docs).thenReturn([profile1_qdsnap, profile2_qdsnap, profile3_qdsnap, profile4_qdsnap]);
    when(profile1_qdsnap.data()).thenReturn({'name':"Adam", 'occupation':"Software Developer"});
    when(profile2_qdsnap.data()).thenReturn({'name':"Eve", 'occupation':"Project Manager"});
    when(profile3_qdsnap.data()).thenReturn({'name':"Steve"});
    when(profile4_qdsnap.data()).thenReturn({'name':"Carol", 'occupation':"Quality Assurance"});

    // List of profiles
    testWidgets('Conference Page Test', (WidgetTester tester) async {
      await tester.pumpWidget(PageWrapper(ConferencePage(firestore, storage, functions, conference)));

      await tester.pump(Duration.zero);
      expect(find.text("Mockference"), findsOneWidget);
      expect(find.text("Profiles"), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.emoji_people), findsOneWidget);

      await tester.pump(Duration.zero);
      verify(firestore.getConferenceProfiles(any)).called(1);
      expect(find.text("Adam"), findsOneWidget);
      expect(find.text("Eve"), findsOneWidget);
      expect(find.text("Steve"), findsOneWidget);
      expect(find.text("Software Developer"), findsOneWidget);
      expect(find.text("Project Manager"), findsOneWidget);

      await tester.pump(Duration.zero);
      expect(find.text("Carol"), findsOneWidget);
      expect(find.text("Quality Assurance"), findsOneWidget);
    });

    // Displaying a profile
    testWidgets('View Profile Details', (WidgetTester tester) async {
      await tester.pumpWidget(PageWrapper(ViewProfileDetailsPage(conference, profile1.uid, firestore, storage)));
    });
  });
}