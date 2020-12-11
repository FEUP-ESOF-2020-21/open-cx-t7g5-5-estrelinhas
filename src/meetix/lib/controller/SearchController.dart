import 'package:algolia/algolia.dart';

class SearchController {
  final search = Algolia.init(
    applicationId: 'EVM4MH9QZA',
    apiKey: 'decb5d40b1b0f918a901af8ff4043d27'
  );

  Future<List<AlgoliaObjectSnapshot>> searchConferences(String search_string) async {
    var query = search.instance.index('conference_search').search(search_string);
    var results = await query.getObjects();
    return results.hits;
  }

}