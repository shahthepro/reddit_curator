import 'package:flutter/material.dart';
import 'package:reddit_curator/data/feed.dart';
import 'package:flutter/cupertino.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:reddit_curator/utils/fetch-feeds.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:reddit_curator/utils/share.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

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
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: const Icon(Icons.menu), 
          onPressed: _showDrawer,
        ),
        title: Text(widget.title),
      ),
      body: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: <BottomNavigationBarItem>[
            new BottomNavigationBarItem(
              icon: new Icon(
                Icons.photo_library,
                color: Colors.blueGrey,
              ),
              activeIcon: new Icon(
                Icons.photo_library,
                color: Colors.redAccent,
              ),
              title: Text("Latest"),
            ),
            new BottomNavigationBarItem(
              icon: new Icon(
                Icons.trending_up,
                color: Colors.blueGrey,
              ),
              activeIcon: new Icon(
                Icons.trending_up,
                color: Colors.redAccent,
              ),
              title: Text("Popular"),
            ),
            new BottomNavigationBarItem(
              icon: new Icon(
                Icons.favorite,
                color: Colors.blueGrey,
              ),
              activeIcon: new Icon(
                Icons.favorite,
                color: Colors.redAccent,
              ),
              title: Text("Favorites"),
            ),
          ],
        ),
        tabBuilder: _buildTabView,
      ),
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
    }
    return _buildRecentTabView();
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
                    print("Share ${feed.id}");
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  
  void _showDrawer() {
    print("Show Drawer");
  }

  void mapImagesToGallery() {
    setState(() {
      _images.addAll(
        _feeds.map((feed) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(feed.link),
            heroTag: feed.title
          );
        })
      );
      _currentFeed = _feeds[0];
    });
  }

  // int _currentIndex = 0;
  FeedItem _currentFeed;
  void _onImageSwiped(int index) {
    setState(() {
      // _currentIndex = index;
      _currentFeed = _feeds[index];
    });
  }

  void _setupImageSwiper({ bool popular = false, favorites = false }) {
    _images.removeRange(0, _images.length);
  }

  void _showImageSwiper({ bool popular = false, favorites = false, int startIndex = 0 }) {
    _setupImageSwiper(popular: popular, favorites: favorites);

    mapImagesToGallery();

    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new Scaffold(
            appBar: new AppBar(
              title: Text("Image Viewer"),
            ),
            body: Container(
              constraints: BoxConstraints.expand(
                height: MediaQuery.of(context).size.height,
              ),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: <Widget>[
                  PhotoViewGallery(
                    pageOptions: _images,
                    // loadingChild: widget.loadingChild,
                    // backgroundDecoration: widget.backgroundDecoration,
                    pageController: PageController(initialPage: startIndex),
                    onPageChanged: _onImageSwiped,
                  ),
                  // Container(
                  //   padding: const EdgeInsets.all(20.0),
                  //   child: Text(_currentFeed.title,
                  //     style: const TextStyle(
                  //         color: Colors.white, fontSize: 17.0, decoration: null),
                  //   ),
                  // )
                ],
              )),
          );
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
    
    // setState(() {
    //   if (popular) {
    //     _popularIndicatorKey.currentState.show(atTop: false);
    //   } else {
    //     _recentIndicatorKey.currentState.show(atTop: false);
    //   }
    // });

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
    // setState(() {
    //   if (popular) {
    //     _popularIndicatorKey.currentState.show(atTop: true);
    //   } else {
    //     _recentIndicatorKey.currentState.show(atTop: true);
    //   }
    // });
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
