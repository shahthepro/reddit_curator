import 'package:flutter/widgets.dart';
import 'package:reddit_curator/data/feed.dart';
import 'package:reddit_curator/utils/favorites.dart';

enum TabViewPages {
  Recent,
  Popular,
  Favorites,
  Options,
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
  String get appTitle => "MediaCurator";

  TabViewPages _activeTab = TabViewPages.Recent;
  TabViewPages get activeTab => _activeTab;

  void setCurrentTabView(int tabIndex) {
    setState(() {
      if (TabViewPages.Recent.index == tabIndex) {
        _activeTab = TabViewPages.Recent;
      } else if (TabViewPages.Popular.index == tabIndex) { 
        _activeTab = TabViewPages.Popular;
      } else if (TabViewPages.Favorites.index == tabIndex) { 
        _activeTab = TabViewPages.Favorites;
      } else if (TabViewPages.Options.index == tabIndex) { 
        _activeTab = TabViewPages.Options;
      }
    });
  }

  int _loaders = 0;

  bool get isLoading => _loaders > 0;

  void asyncJobStarted() {
    setState(() {
      _loaders++;
    });
  }

  void asyncJobCompleted() {
    setState(() {
      _loaders--;
    });
  }
  
  bool _shouldShowAds = true;
  bool get shouldShowAds => _shouldShowAds;

  final _feeds = List<FeedItem>();
  final _popular = List<FeedItem>();
  final _savedIds = Set<String>();
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

  void prependFeeds(List<FeedItem> feeds, { popular = false }) {
    setState(() {
      if (popular) {
        _popular.insertAll(0, feeds);
      } else {
        _feeds.insertAll(0, feeds);
      }
    });
  }

  bool isFavorite(FeedItem feed)  {
    return _savedIds.contains(feed.id);
  }

  void favoriteFeed(FeedItem feed) {
    final alreadySaved = isFavorite(feed);

    setState(() {
      if (alreadySaved) {
        _savedIds.remove(feed.id);
        _savedItemsMap.remove(feed.id);
        removeFavorite(feed);
      } else {
        _savedIds.add(feed.id);
        _savedItemsMap[feed.id] = feed;
        storeFavorite(feed);
      }
    });
  }

  void loadFavorites(List<FeedItem> favorites) {
    setState(() {
      for (int i = 0; i < favorites.length; i++) {
        _savedIds.add(favorites[i].id);
        _savedItemsMap[favorites[i].id] = favorites[i];
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