// import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:reddit_curator/components/card-view.dart';
import 'package:reddit_curator/components/settings.dart';
import 'package:reddit_curator/data/feed.dart';
import 'package:flutter/cupertino.dart';
// import 'package:sqflite/sqflite.dart';
import 'package:reddit_curator/screens/image-viewer.dart';
import 'package:reddit_curator/store/state.dart';
import 'package:reddit_curator/utils/ads.dart';
import 'package:reddit_curator/utils/favorites.dart';
import 'package:reddit_curator/utils/fetch-feeds.dart';
import 'package:reddit_curator/utils/share.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> with NavigatorObserver {
  bool _loadedFromDatabase = false;

  @override
  void initState() {
    super.initState();

    // createAndShowBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    final AppStateWidgetState state = AppStateWidget.of(context);

    if (!_loadedFromDatabase) {
      _loadedFromDatabase = true;

      // if (state.shouldShowAds) {
      //   createAndShowBannerAd();
      // }

      getAllFavorites().then((favs) { state.loadFavorites(favs); });
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(state.appTitle),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CupertinoTabScaffold(
            tabBar: _getBottomTabBar(state),
            tabBuilder: _buildTabView,
          ),
          Positioned(
            child: Visibility(
              visible: state.isLoading,
              child: CircularProgressIndicator(),
            ),
            bottom: 60,
          ),
        ],
      )
    );
  }

  @override
  void dispose() {
    disposeAllAds();
    super.dispose();
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
        return _buildSettingsView(context);
    }
    return _buildRecentTabView();
  }

  Widget _buildSettingsView(BuildContext rootContext) {
    return new CupertinoTabView(
      builder: (BuildContext context) {
        return getSettingsPage(rootContext);
      },
    );
  }

  Widget _buildRecentTabView() {
    return new CupertinoTabView(
      builder: (BuildContext context) {
        final AppStateWidgetState state = AppStateWidget.of(context);
        
        return new RefreshIndicator(
          child: ListView.builder(
            itemBuilder: _buildRecentListView,
          ),
          onRefresh: () {
            return _fetchNewFeeds();
          },
        );
      },
    );
  }

  Widget _buildPopularTabView() {
    return new CupertinoTabView(
      builder: (BuildContext context) {
        final AppStateWidgetState state = AppStateWidget.of(context);

        return new RefreshIndicator(
          child: ListView.builder(
            itemBuilder: _buildPopularListView,
          ),
          onRefresh: () {
            return _fetchNewFeeds(popular: true);
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

    if (index > state.feedsCount) {
      return null;
    }

    if (index >= state.feedsCount) {
      return new FutureBuilder(
        future: _fetchOldFeeds(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return _buildRow(state.recentFeeds[index], index: index);
          } else {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(50.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      );
    }

    return _buildRow(state.recentFeeds[index], index: index);
  }

  Widget _buildPopularListView(BuildContext context, int index) {
    AppStateWidgetState state = AppStateWidget.of(context);

    if (index > state.popularCount) {
      return null;
    }

    if (index >= state.popularCount) {
      return new FutureBuilder(
        future: _fetchOldFeeds(popular: true),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return _buildRow(state.popularFeeds[index], popular: true, index: index);
          } else {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(50.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      );
    }

    return _buildRow(state.popularFeeds[index], popular: true, index: index);
  }

  Widget _buildRow(FeedItem feed, { popular = false, favorites = false, index = 0 }) {
    AppStateWidgetState state = AppStateWidget.of(context);

    final card = buildCard(
      feed,
      context: context,
      onImageTap: () {
        _showImageSwiper(startIndex: index);
      },
      onDownload: _onFeedDownload,
      onShare: _onFeedShare,
      onFavorite: _onFeedFavorite,
    );

    // if (state.shouldShowAds && (index + 1) % 6 == 0) {
    //   return Column(children: <Widget>[
    //     card,
    //     Padding(
    //       padding: EdgeInsets.all(30.0),
    //       child:getBannerAd(),
    //     ),
    //   ]);
    // }

    return card;
  }

  void _onFeedDownload({ FeedItem feed, AppStateWidgetState state }) async {
    if (state.shouldShowAds) {
      await showInterstitialAdIfNecessary();
    }
    downloadImage(feed.link);
  }
  void _onFeedShare({ FeedItem feed, AppStateWidgetState state }) async {
    if (state.shouldShowAds) {
      await showInterstitialAdIfNecessary();
    }
    shareImage(feed.link);
  }
  void _onFeedFavorite({ FeedItem feed, AppStateWidgetState state }) async {
    if (state.shouldShowAds) {
      await showInterstitialAdIfNecessary();
    }
    state.favoriteFeed(feed);
  }

  void _showImageSwiper({ int startIndex = 0 }) async {
    disposeBannerAd();
    await Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new ImageViewerScreen(
            startIndex: startIndex,
            onDownload: _onFeedDownload,
            onShare: _onFeedShare,
            onFavorite: _onFeedFavorite,
          );
        }
      )
    );
    // createAndShowBannerAd();
  }

  Future<void> _fetchOldFeeds({bool popular = false}) async {
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

  Future<void> _fetchNewFeeds({bool popular = false}) async {
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


  // @override
  // void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
  //   // AppStateWidgetState state = AppStateWidget.of(context);

  //   // if (state.shouldShowAds) {
  //   createAndShowBannerAd();
  //   // }
  // }
}
