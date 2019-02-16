import 'package:flutter/material.dart';
import 'package:reddit_curator/data/feed.dart';
import 'package:flutter/cupertino.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:reddit_curator/screens/image-viewer.dart';
import 'package:reddit_curator/store/state.dart';
import 'package:reddit_curator/utils/fetch-feeds.dart';
import 'package:reddit_curator/utils/share.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _feeds = <FeedItem>[];
  final _popular = <FeedItem>[];
  final _saved = new Set<String>();
  final _savedItemsMap = new Map<String, FeedItem>();
  final _images = <PhotoViewGalleryPageOptions>[];

  final GlobalKey<RefreshIndicatorState> _recentIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _popularIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final AppStateWidgetState state = AppStateWidget.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.appTitle),
      ),
      body: CupertinoTabScaffold(
        tabBar: _getBottomTabBar(state),
        tabBuilder: _buildTabView,
      ),
    );
  }

  Widget _getBottomTabBar(AppStateWidgetState state) {
    return CupertinoTabBar(
      onTap: state.setCurrentTabView,
      items: <BottomNavigationBarItem>[
        _getBottomTabItem(icon: Icons.photo_library, title: "Latest"),
        _getBottomTabItem(icon: Icons.trending_up, title: "Popular"),
        _getBottomTabItem(icon: Icons.favorite, title: "Favorites"),
        _getBottomTabItem(icon: Icons.more_horiz, title: "More"),
      ],
    );
  }

  BottomNavigationBarItem _getBottomTabItem({IconData icon, String title}) {
    return new BottomNavigationBarItem(
      icon: new Icon(icon, color: Colors.blueGrey),
      activeIcon: new Icon(icon, color: Colors.redAccent),
      title: Text(title),
    );
  }

  Widget _buildTabView(BuildContext context, int index) {
    switch (index) {
      case 0:
        return _buildRecentTabView();
      case 1:
        return _buildPopularTabView();
      case 2:
        return _buildFavoritesTabView();
      case 3:
        return _buildSettingsView();
    }
    return _buildRecentTabView();
  }

  Widget _buildSettingsView() {
    return new CupertinoTabView(
      builder: (BuildContext context) {
        return Text("Settings Page");
      },
    );
  }

  Widget _buildRecentTabView() {
    return new CupertinoTabView(
      builder: (BuildContext context) {
        return new RefreshIndicator(
          child: ListView.builder(
            itemBuilder: _buildRecentListView,
          ),
          onRefresh: _fetchNewFeeds,
          key: _recentIndicatorKey,
        );
      },
    );
  }

  Widget _buildPopularTabView() {
    return new CupertinoTabView(
      builder: (BuildContext context) {
        return new RefreshIndicator(
          child: ListView.builder(
            itemBuilder: _buildPopularListView,
          ),
          onRefresh: () {
            _fetchNewFeeds(popular: true);
          },
          key: _popularIndicatorKey,
        );
      },
    );
  }

  Widget _buildFavoritesTabView() {
    return new CupertinoTabView(
      builder: (BuildContext context) {
        return ListView.builder(
          reverse: true,
          itemBuilder: _buildFavoritesListView,
        );
      }
    );
  }

  Widget _buildFavoritesListView(BuildContext context, int index) {
    if (index >= _saved.length) {
      return null;
    }

    return _buildRow(_savedItemsMap[_saved.skip(index).take(1).single], favorites: true, index: index);
  }

  Widget _buildRecentListView(BuildContext context, int index) {
    if (index + 10 >= _feeds.length) {
      _fetchOldFeeds();
      return null;
    }

    return _buildRow(_feeds[index], index: index);
  }

  Widget _buildPopularListView(BuildContext context, int index) {
    if (index + 10 >= _popular.length) {
      _fetchOldFeeds(popular: true);
      return null;
    }

    return _buildRow(_popular[index], popular: true, index: index);
  }

  Widget _buildRow(FeedItem feed, { popular = false, favorites = false, index = 0 }) {
    final alreadySaved = _saved.contains(feed.id);

    return Card(
      key: Key(feed.id),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(feed.title),
            subtitle: Text(feed.timestamp),
          ),
          new GestureDetector(
            onTap: () {
              _showImageSwiper(popular: popular, favorites: favorites, startIndex: index);
            },
            child: Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new NetworkImage(feed.link),
                  fit: BoxFit.cover,
                ),
              ),
              height: 250.0,
            ),
          ),
          ButtonTheme.bar(
            child: ButtonBar(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    alreadySaved ? Icons.favorite : Icons.favorite_border,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    setState(() {
                      if (alreadySaved) {
                        _saved.remove(feed.id);
                        _savedItemsMap.remove(feed.id);
                      } else {
                        _saved.add(feed.id);
                        _savedItemsMap[feed.id] = feed;
                      }
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.cloud_download,
                    color: Colors.blueGrey,
                  ),
                  onPressed: () async {
                    downloadImage(feed.link);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.share,
                    color: Colors.blueGrey
                  ),
                  onPressed: () {
                    shareImage(feed.link);
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showImageSwiper({ bool popular = false, favorites = false, int startIndex = 0 }) {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new ImageViewerScreen(startIndex: startIndex);
          // return AppStateWidget(
          //   child: new ImageViewerScreen(startIndex: startIndex),
          // );
        }
      )
    );
  }

  Future<FeedItem> _fetchOldFeeds({bool popular = false}) async {
    String after = "";
    if (popular && _popular.length > 0) {
      after = _popular.last.id;
    } else if (!popular && _feeds.length > 0) {
      after = _feeds.last.id;
    }

    return fetchData(popular: popular, after: after)
      .then((newData) {
        setState(() {
          if (popular) {
            _popular.addAll(newData);
          } else {
            _feeds.addAll(newData);
          }      
        });
      });
  }

  Future<FeedItem> _fetchNewFeeds({bool popular = false}) async {
    String before = "";
    if (popular && _popular.length > 0) {
      before = _popular.first.id;
    } else if (!popular && _feeds.length > 0) {
      before = _feeds.first.id;
    }

    return fetchData(popular: popular, before: before)
      .then((newData) {
        setState(() {
          if (popular) {
            _popular.insertAll(0, newData);
          } else {
            _feeds.insertAll(0, newData);
          }      
        });
      });
  }
}
