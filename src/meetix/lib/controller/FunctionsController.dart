import 'package:cloud_functions/cloud_functions.dart';

class FunctionsController {
  static final FirebaseFunctions functions = FirebaseFunctions.instance;

  Future<List<List<String>>> getTop20(String profileID, String conferenceID) async {
    HttpsCallable function = functions.httpsCallable('getTop20');

    final results =  await function.call({'profileID' : profileID, 'conferenceID' : conferenceID});

    List<List<String>> ret = [];
    for (var result in results.data) {
      List<String> entry = [];
      for (var field in result) {
        entry.add(field.toString());
      }
      ret.add(entry);
    }

    return ret;
  }

  Future<void> deleteConference(String conferenceID) async {
    HttpsCallable function = functions.httpsCallable('deleteConferenceOrProfile');

    await function.call({
      'conferenceID' : conferenceID,
      'type' : 'conference',
    });
  }

  Future<void> deleteProfile(String conferenceID, String profileID) async {
    HttpsCallable function = functions.httpsCallable('deleteConferenceOrProfile');

    await function.call({
      'conferenceID' : conferenceID,
      'profileID' : profileID,
      'type' : 'profile',
    });
  }
}