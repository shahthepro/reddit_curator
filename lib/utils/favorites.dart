import 'package:reddit_curator/data/db.dart';
import 'package:reddit_curator/data/feed.dart';

Future<List<FeedItem>> getAllFavorites() async {
  final database = await getDatabase();

  List<FeedItem> favorites = new List<FeedItem>();

  try {
    List<Map<String, dynamic>> rows = await database.query("favorites", where: "favorite=1"); 

    favorites = rows.map((m) {
      return new FeedItem(
        m['id'],
        m['title'],
        m['link'],
        m['timestamp'],
        0,
      );
    }).toList();

    print(favorites.length);
  } on Exception catch (e) {
    print(e);
  }

  return favorites;
}

Future<void> storeFavorite(FeedItem feed) async {
  final database = await getDatabase();

  Map<String, dynamic> data = new Map<String, dynamic>();
  data['id'] = feed.id;
  data['title'] = feed.title;
  data['link'] = feed.link;
  data['timestamp'] = feed.timestamp;
  data['favorite'] = 1;

  await database.insert("favorites", data);
}

Future<void> removeFavorite(FeedItem feed) async {
  final database = await getDatabase();

  await database.delete("favorites", where: "id=${feed.id}");
}