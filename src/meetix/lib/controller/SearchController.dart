import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchController {
  final search = Algolia.init(
    applicationId: 'EVM4MH9QZA',
    apiKey: 'decb5d40b1b0f918a901af8ff4043d27'
  );

  Future<List<AlgoliaObjectSnapshot>> searchConferences(String search_string) async {
    var query = search.instance.index('conference_search')
        .search(search_string)
        .setNumericFilter('endDate_timestamp>'+Timestamp.now().seconds.toString());

    var results = await query.getObjects();
    return results.hits;
  }

  Future<List<AlgoliaObjectSnapshot>> searchProfiles(String confID, String profileID, String search_string) async {
    var query = search.instance.index(confID + '_profiles')
        .search(search_string);

    var results = await query.getObjects();
    return results.hits;
  }
}