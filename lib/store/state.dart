import 'package:flutter/widgets.dart';
import 'package:reddit_curator/data/feed.dart';

class Item {
   String reference;

   Item(this.reference);
}

class _AppState extends InheritedWidget {
  _AppState({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  final AppStateWidgetState data;

  @override
  bool updateShouldNotify(_AppState oldWidget) {
    return true;
  }
}

class AppStateWidget extends StatefulWidget {
  AppStateWidget({
    Key key,
    this.child,
  }): super(key: key);

  final Widget child;

  @override
  AppStateWidgetState createState() => new AppStateWidgetState();

  static AppStateWidgetState of(BuildContext context){
    return (context.inheritFromWidgetOfExactType(_AppState) as _AppState).data;
  }
}

class AppStateWidgetState extends State<AppStateWidget>{
  final _feeds = List<FeedItem>();
  final _popular = List<FeedItem>();
  final _savedItemsMap = new Map<String, FeedItem>();

  int get feedsCount => _feeds.length;
  int get popularCount => _popular.length;
  int get savedCount => _savedItemsMap.keys.length;

  List<FeedItem> get recentFeeds => _feeds;
  List<FeedItem> get popularFeeds => _popular;
  List<FeedItem> get favoriteFeeds => _savedItemsMap.values.toList();

  void addFeed(FeedItem feed, { popular = false }) {
    setState(() {
      if (popular) {
        _popular.add(feed);
      } else {
        _feeds.add(feed);
      }
    });
  }

  void appendFeeds(List<FeedItem> feeds, { popular = false }) {
    setState(() {
      if (popular) {
        _popular.addAll(feeds);
      } else {
        _feeds.addAll(feeds);
      }
    });
  }

  bool isFavorite(FeedItem feed)  {
    return _savedItemsMap.containsKey(feed);
  }

  void favoriteFeed(FeedItem feed) {
    final alreadySaved = _savedItemsMap.containsKey(feed);

    setState(() {
      if (alreadySaved) {
        _savedItemsMap.remove(feed.id);
      } else {
        _savedItemsMap[feed.id] = feed;
      }
    });
  }

  @override
  Widget build(BuildContext context){
    return new _AppState(
      data: this,
      child: widget.child,
    );
  }
}