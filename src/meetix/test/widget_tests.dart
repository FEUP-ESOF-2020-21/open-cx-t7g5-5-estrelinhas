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
import 'package:meetix/view/conferences/ConferenceListPage.dart';
import 'package:meetix/view/conferences/ConferencePage.dart';
import 'package:meetix/view/profiles/ViewProfileDetailsPage.dart';
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
    when(user.displayName).thenReturn("User");

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
  group('Profile and Conference List View', () {
    // Mocks for controllers
    var firestore = MockFirestore();
    var storage = MockStorage();
    var functions = MockFunctions();

    // Mocks for conference data
    var conferencesQsnap1 = MockQSnapshot();
    var conferencesQsnap2 = MockQSnapshot();
    var conference1 = MockConference();
    var conference1Qsnap = MockQSnapshot();
    var conference1Dref = MockDRef();
    var conference1QDsnap = MockQDSnapshot();
    var conference2 = MockConference();
    var conference2Qsnap = MockQSnapshot();
    var conference2Dref = MockDRef();
    var conference2QDsnap = MockQDSnapshot();
    var conference3 = MockConference();
    var conference3Qsnap = MockQSnapshot();
    var conference3Dref = MockDRef();
    var conference3QDsnap = MockQDSnapshot();

    // Mocks for profile data
    var profilesQsnap1 = MockQSnapshot();
    var profilesQsnap2 = MockQSnapshot();
    var profile1QDsnap = MockQDSnapshot();
    var profile1Qsnap = MockQSnapshot();
    var profile2QDsnap = MockQDSnapshot();
    var profile3QDsnap = MockQDSnapshot();
    var profile3Qsnap = MockQSnapshot();
    var profile4QDsnap = MockQDSnapshot();

    // CONFERENCES
    // Setting values for conference data
    when(conference1.uid).thenReturn("user");
    when(conference1.reference).thenReturn(conference1Dref);
    when(conference1Dref.id).thenReturn("1");
    when(conference1Qsnap.size).thenReturn(1);
    when(conference1Qsnap.docs).thenReturn([conference1QDsnap]);
    when(conference1QDsnap.data()).thenReturn({'name':"Mockference", 'start_date':Timestamp(1607878030, 0), 'end_date':Timestamp(1607888030, 0)});
    when(conference1QDsnap.reference).thenReturn(conference1Dref);

    when(conference2.uid).thenReturn("user");
    when(conference2.reference).thenReturn(conference2Dref);
    when(conference2Dref.id).thenReturn("2");
    when(conference2Qsnap.size).thenReturn(1);
    when(conference2Qsnap.docs).thenReturn([conference2QDsnap]);
    when(conference2QDsnap.data()).thenReturn({'name':"ESOFerence", 'start_date':Timestamp(1607678030, 0), 'end_date':Timestamp(1607888030, 0)});
    when(conference2QDsnap.reference).thenReturn(conference2Dref);

    when(conference3.uid).thenReturn("user");
    when(conference3.reference).thenReturn(conference3Dref);
    when(conference3Dref.id).thenReturn("3");
    when(conference3Qsnap.size).thenReturn(1);
    when(conference3Qsnap.docs).thenReturn([conference3QDsnap]);
    when(conference3QDsnap.data()).thenReturn({'name':"MIEICference", 'start_date':Timestamp(1607578030, 0), 'end_date':Timestamp(1607888030, 0)});
    when(conference3QDsnap.reference).thenReturn(conference3Dref);

    when(conferencesQsnap1.size).thenReturn(3);
    when(conferencesQsnap1.docs).thenReturn([conference1QDsnap, conference2QDsnap, conference3QDsnap]);

    when(conferencesQsnap2.size).thenReturn(0);

    // Stream for getting conference info
    when(firestore.getConferenceById("1")).thenAnswer((_) {
      return Stream<MockQSnapshot>.value(conference1Qsnap);
    });
    when(firestore.getConferenceById("2")).thenAnswer((_) {
      return Stream<MockQSnapshot>.value(conference2Qsnap);
    });
    when(firestore.getConferenceById("3")).thenAnswer((_) {
      return Stream<MockQSnapshot>.value(conference3Qsnap);
    });


    // PROFILES
    // Setting profile data
    when(profile1QDsnap.data()).thenReturn({
      'name':"Adam",
      'occupation':"Software Developer",
      'location':"Porto",
      'email':"adam@email.com",
      'phone':"111111111",
      'interests':['Flutter', 'Dart', 'Software Engineering']
    });
    when(profile2QDsnap.data()).thenReturn({
      'name':"Eve",
      'occupation':"Project Manager"
    });
    when(profile3QDsnap.data()).thenReturn({
      'name':"Steve"
    });
    when(profile4QDsnap.data()).thenReturn({
      'name':"Carol",
      'occupation':"Quality Assurance"
    });

    // Stream and results for listing profiles
    when(firestore.getConferenceProfiles(any)).thenAnswer((_) {
      return Stream<MockQSnapshot>.value(profilesQsnap1);
    });
    when(profilesQsnap1.size).thenReturn(3);
    when(profilesQsnap1.docs).thenReturn([profile1QDsnap, profile2QDsnap, profile3QDsnap, profile4QDsnap]);
    when(profilesQsnap2.size).thenReturn(0);

    when(firestore.getProfileById(any, "1")).thenAnswer((_) {
      return Stream<MockQSnapshot>.value(profile1Qsnap);
    });
    when(profile1Qsnap.size).thenReturn(1);
    when(profile1Qsnap.docs).thenReturn([profile1QDsnap]);

    when(firestore.getProfileById(any, "3")).thenAnswer((_) {
      return Stream<MockQSnapshot>.value(profile3Qsnap);
    });
    when(profile3Qsnap.size).thenReturn(1);
    when(profile3Qsnap.docs).thenReturn([profile3QDsnap]);


    // TESTS
    // Displaying a list of profiles for a conference that has 4 profiles
    testWidgets('View List of Profiles', (WidgetTester tester) async {
      when(firestore.getActiveConferences()).thenAnswer((_) {
        return Stream<MockQSnapshot>.value(conferencesQsnap1);
      });

      await tester.pumpWidget(PageWrapper(ConferencePage(firestore, storage, functions, conference1)));

      await tester.pump(Duration.zero);
      expect(find.text("Mockference"), findsOneWidget);
      expect(find.text("Profiles"), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.emoji_people), findsOneWidget);

      await tester.pump(Duration.zero);
      verify(firestore.getConferenceProfiles(any)).called(1);
      expect(find.byIcon(Icons.connect_without_contact_rounded), findsNWidgets(4));
      expect(find.text("Adam"), findsOneWidget);
      expect(find.text("Software Developer"), findsOneWidget);
      expect(find.text("Eve"), findsOneWidget);
      expect(find.text("Project Manager"), findsOneWidget);
      expect(find.text("Steve"), findsOneWidget);
      expect(find.text("Carol"), findsOneWidget);
      expect(find.text("Quality Assurance"), findsOneWidget);
    });

    // Displaying a list of profiles for a conference that has 0 profiles
    testWidgets('View List of Profiles No Profiles', (WidgetTester tester) async {
      when(firestore.getConferenceProfiles(any)).thenAnswer((_) {
        return Stream<MockQSnapshot>.value(profilesQsnap2);
      });

      await tester.pumpWidget(PageWrapper(ConferencePage(firestore, storage, functions, conference1)));

      await tester.pump(Duration.zero);
      expect(find.text("Mockference"), findsOneWidget);
      expect(find.text("Profiles"), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.emoji_people), findsOneWidget);

      await tester.pump(Duration.zero);
      verify(firestore.getConferenceProfiles(any)).called(1);
      expect(find.byIcon(Icons.connect_without_contact_rounded), findsNothing);
      expect(find.text("No profiles"), findsOneWidget);
    });

    // Displaying a profile with all the information fields
    testWidgets('View Profile Details All Fields', (WidgetTester tester) async {
      await tester.pumpWidget(PageWrapper(ViewProfileDetailsPage(conference1, '1', firestore, storage)));

      await tester.pump(Duration.zero);
      expect(find.byIcon(Icons.thumb_up_sharp), findsOneWidget);
      expect(find.text('Like'), findsOneWidget);

      expect(find.text("Adam"), findsOneWidget);
      expect(find.text("Adam's Profile"), findsOneWidget);
      expect(find.text("Occupation"), findsOneWidget);
      expect(find.text("Software Developer"), findsOneWidget);
      expect(find.text("Location"), findsOneWidget);
      expect(find.text("Porto"), findsOneWidget);
      expect(find.text("E-mail"), findsOneWidget);
      expect(find.text("adam@email.com"), findsOneWidget);
      expect(find.text("Phone number"), findsOneWidget);
      expect(find.text("111111111"), findsOneWidget);

      final gesture = await tester.startGesture(Offset(100, 300));
      await gesture.moveBy(const Offset(0, -200));
      await tester.pump(Duration.zero);
      expect(find.text("Interests"), findsOneWidget);
      expect(find.text("Flutter"), findsOneWidget);
      expect(find.text("Dart"), findsOneWidget);
      expect(find.text("Software Engineering"), findsOneWidget);
    });

    // Displaying a profile that has no information fields
    testWidgets('View Profile Details No Fields', (WidgetTester tester) async {
      await tester.pumpWidget(PageWrapper(ViewProfileDetailsPage(conference1, '3', firestore, storage)));

      await tester.pump(Duration.zero);
      expect(find.byIcon(Icons.thumb_up_sharp), findsOneWidget);
      expect(find.text('Like'), findsOneWidget);
      expect(find.text("Steve"), findsOneWidget);
      expect(find.text("Steve's Profile"), findsOneWidget);
      expect(find.text("Occupation"), findsNothing);
      expect(find.text("Location"), findsNothing);
      expect(find.text("E-mail"), findsNothing);
      expect(find.text("Phone number"), findsNothing);

      final gesture = await tester.startGesture(Offset(100, 300));
      await gesture.moveBy(const Offset(0, -200));
      await tester.pump(Duration.zero);
      expect(find.text("Interests"), findsNothing);
    });

    // Displaying a list of conferences given there are 3 conferences
    testWidgets('View List of Conferences', (WidgetTester tester) async {
      await tester.pumpWidget(PageWrapper(ConferenceListPage(firestore, storage, functions)));

      await tester.pump(Duration.zero);
      
      expect(find.text("Available Conferences"), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsNWidgets(3));

      verify(firestore.getActiveConferences()).called(1);
      expect(find.text('Mockference'), findsOneWidget);
      expect(find.text('ESOFerence'), findsOneWidget);
      expect(find.text('MIEICference'), findsOneWidget);

    });

    // Displaying a list of conferences given there are 0 conferences
    testWidgets('View List of Conferences No Conferences', (WidgetTester tester) async {
      when(firestore.getActiveConferences()).thenAnswer((_) {
        return Stream<MockQSnapshot>.value(conferencesQsnap2);
      });

      await tester.pumpWidget(PageWrapper(ConferenceListPage(firestore, storage, functions)));

      await tester.pump(Duration.zero);
      verify(firestore.getActiveConferences()).called(1);
      expect(find.text("Available Conferences"), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsNothing);
      expect(find.text('There are no active conferences'), findsOneWidget);
    });
  });
}