import 'package:flutter/material.dart';
import 'package:reddit_curator/data/feed.dart';
import 'package:flutter/cupertino.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
  bool _isLoadingOldFeeds = false;


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

    return _buildRow(_savedItemsMap[_saved.skip(index).take(1).single]);
  }

  Widget _buildRecentListView(BuildContext context, int index) {
    if (index >= _feeds.length) {
      _fetchOldFeeds();
      return null;
    }

    return _buildRow(_feeds[index]);
  }

  Widget _buildPopularListView(BuildContext context, int index) {
    if (index >= _popular.length) {
      _fetchOldFeeds(popular: true);
      return null;
    }

    return _buildRow(_popular[index]);
  }

  Widget _buildRow(FeedItem feed) {
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
            onTap: _showImageSwiper,
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
                  onPressed: () {
                    print("Download ${feed.id}");
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

  int _currentIndex = 0;
  FeedItem _currentFeed;
  void _onImageSwiped(int index) {
    setState(() {
      _currentIndex = index;
      _currentFeed = _feeds[index];
    });
  }

  void _showImageSwiper() {
    _currentIndex = 0;
    _images.removeRange(0, _images.length);
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
                    // pageController: widget.pageController,
                    onPageChanged: _onImageSwiped,
                  ),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(_currentFeed.title,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 17.0, decoration: null),
                    ),
                  )
                ],
              )),
          );
        }
      )
    );
  }

  Future<void> _fetchOldFeeds({bool popular = false}) async {
    this._isLoadingOldFeeds = true;
    
    return Future.delayed(new Duration(seconds: 2), () {
      setState(() {
        this._isLoadingOldFeeds = false;
        if (popular) {
          int startId = _popular.length;
          _popular.addAll([
            new FeedItem("id_$startId", "Popular Feed ${startId}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 1}", "Popular Feed ${startId + 1}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 2}", "Popular Feed ${startId + 2}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 3}", "Popular Feed ${startId + 3}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 4}", "Popular Feed ${startId + 4}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 5}", "Popular Feed ${startId + 5}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 6}", "Popular Feed ${startId + 6}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 7}", "Popular Feed ${startId + 7}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 8}", "Popular Feed ${startId + 8}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 9}", "Popular Feed ${startId + 9}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
          ]);
        } else {
          int startId = _feeds.length;
          _feeds.addAll([
            new FeedItem("id_$startId", "Feed Item ${startId}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 1}", "Feed Item ${startId + 1}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 2}", "Feed Item ${startId + 2}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 3}", "Feed Item ${startId + 3}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 4}", "Feed Item ${startId + 4}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 5}", "Feed Item ${startId + 5}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 6}", "Feed Item ${startId + 6}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 7}", "Feed Item ${startId + 7}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 8}", "Feed Item ${startId + 8}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 9}", "Feed Item ${startId + 9}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
          ]);
        }
      });
    });
  }

  Future<void> _fetchNewFeeds({bool popular = false}) async {
    return Future.delayed(new Duration(seconds: 2), () {
      setState(() {
        if (popular) {
          int startId = _popular.length;
          _popular.insertAll(0, [
            new FeedItem("id_$startId", "Popular Feed ${startId}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 1}", "Popular Feed ${startId + 1}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 2}", "Popular Feed ${startId + 2}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 3}", "Popular Feed ${startId + 3}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 4}", "Popular Feed ${startId + 4}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 5}", "Popular Feed ${startId + 5}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 6}", "Popular Feed ${startId + 6}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 7}", "Popular Feed ${startId + 7}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 8}", "Popular Feed ${startId + 8}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 9}", "Popular Feed ${startId + 9}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
          ]);
        } else {
          int startId = _feeds.length;
          _feeds.insertAll(0, [
            new FeedItem("id_$startId", "Feed Item ${startId}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 1}", "Feed Item ${startId + 1}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 2}", "Feed Item ${startId + 2}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 3}", "Feed Item ${startId + 3}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 4}", "Feed Item ${startId + 4}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 5}", "Feed Item ${startId + 5}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 6}", "Feed Item ${startId + 6}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 7}", "Feed Item ${startId + 7}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 8}", "Feed Item ${startId + 8}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
            new FeedItem("id_${startId + 9}", "Feed Item ${startId + 9}", "https://preview.redd.it/56ot0vqsvif21.jpg?width=640&crop=smart&auto=webp&s=22fbf9ad69942e7a4c4d4e442daa0cadf97ffbd4", "11h ago", 0),
          ]);
        }
      });
    });
  }
}
