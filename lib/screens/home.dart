import 'package:flutter/material.dart';
import 'package:reddit_curator/components/card-view.dart';
import 'package:reddit_curator/data/feed.dart';
import 'package:flutter/cupertino.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:photo_view/photo_view.dart';
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

  @override
  Widget build(BuildContext context) {
    final AppStateWidgetState state = AppStateWidget.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
        );
      },
    );
  }

  Widget _buildFavoritesTabView() {
    return new CupertinoTabView(
      builder: (BuildContext context) {
        return ListView.builder(
          itemBuilder: _buildFavoritesListView,
        );
      }
    );
  }

  Widget _buildFavoritesListView(BuildContext context, int index) {
    AppStateWidgetState state = AppStateWidget.of(context);

    if (index >= state.savedCount) {
      return null;
    }

    int reversedIndex = (state.savedCount - 1 - index);

    return _buildRow(state.favoriteFeeds[reversedIndex], favorites: true, index: index);
  }

  Widget _buildRecentListView(BuildContext context, int index) {
    AppStateWidgetState state = AppStateWidget.of(context);

    if (index >= state.feedsCount) {
      _fetchOldFeeds();
      return null;
    }

    return _buildRow(state.recentFeeds[index], index: index);
  }

  Widget _buildPopularListView(BuildContext context, int index) {
    AppStateWidgetState state = AppStateWidget.of(context);

    if (index >= state.popularCount) {
      _fetchOldFeeds(popular: true);
      return null;
    }

    return _buildRow(state.popularFeeds[index], popular: true, index: index);
  }

  Widget _buildRow(FeedItem feed, { popular = false, favorites = false, index = 0 }) {
    AppStateWidgetState state = AppStateWidget.of(context);

    return buildCard(
      feed,
      context: context,
      onImageTap: () { _showImageSwiper(startIndex: index); },
      onDownload: () { downloadImage(feed.link); },
      onShare: () { shareImage(feed.link); },
      onFavorite: () { state.favoriteFeed(feed); },
    );
  }

  void _showImageSwiper({ int startIndex = 0 }) {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new ImageViewerScreen(startIndex: startIndex);
        }
      )
    );
  }

  Future<FeedItem> _fetchOldFeeds({bool popular = false}) async {
    AppStateWidgetState state = AppStateWidget.of(context);

    String after = "";
    if (popular && state.popularCount > 0) {
      after = state.popularFeeds.last.id;
    } else if (!popular && state.feedsCount > 0) {
      after = state.recentFeeds.last.id;
    }

    return fetchData(popular: popular, after: after)
      .then((newData) {
        state.appendFeeds(newData, popular: popular);
      });
  }

  Future<FeedItem> _fetchNewFeeds({bool popular = false}) async {
    AppStateWidgetState state = AppStateWidget.of(context);

    String before = "";
    if (popular && state.popularCount > 0) {
      before = state.popularFeeds.first.id;
    } else if (!popular && state.feedsCount > 0) {
      before = state.recentFeeds.first.id;
    }

    return fetchData(popular: popular, before: before)
      .then((newData) {
        state.prependFeeds(newData, popular: popular);
      });
  }
}
