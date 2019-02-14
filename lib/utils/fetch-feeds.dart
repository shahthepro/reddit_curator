import 'package:reddit_curator/data/feed.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

final _newBaseURL = "https://reddit.com/r/AnimalsBeingBros+AnimalsBeingDerps+AnimalsBeingJerks+Awwducational+aww+cats+dogs+likeus+rarepuppers/search.rss?q=site%3A(i.redd.it+OR+i.imgur.com)&sort=new&restrict_sr=on&t=all";
final _popularBaseURL = "https://reddit.com/r/AnimalsBeingBros+AnimalsBeingDerps+AnimalsBeingJerks+Awwducational+aww+cats+dogs+likeus+rarepuppers/search.rss?q=site%3A(i.redd.it+OR+i.imgur.com)&sort=popular&restrict_sr=on&t=all";

Future<List<FeedItem>> fetchData({ popular = false, before = "", after = "" }) {
  String url = popular ? _popularBaseURL : _newBaseURL;
  if (before.length > 0) {
    url = url + "&before=" + before;
  } else if (after.length > 0) {
    url = url + "&after=" + after;
  }

  return _fetchDataFromURL(url);
}

Future<List<FeedItem>> _fetchDataFromURL(String url) async {
  return http.get(url).then((response) {
    var data = new List<FeedItem>();
    final doc = xml.parse(response.body.toString());
    final entries = doc.findAllElements('entry');

    print(entries.length);

    return data;
  });
}