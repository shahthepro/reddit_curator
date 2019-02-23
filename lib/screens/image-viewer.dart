import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:reddit_curator/components/bottom-button-bar.dart';
import 'package:reddit_curator/data/feed.dart';
import 'package:flutter/cupertino.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:reddit_curator/store/state.dart';
import 'package:reddit_curator/utils/ads.dart';

class ImageViewerScreen extends StatefulWidget {
  ImageViewerScreen({ Key key, this.startIndex = 0, this.onFavorite, this.onShare, this.onDownload }) : super(key: key);

  final int startIndex;
  final Function onFavorite;
  final Function onDownload;
  final Function onShare;

  @override
  _ImageViewerScreenState createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  final List<PhotoViewGalleryPageOptions> _images = List<PhotoViewGalleryPageOptions>();
  FeedItem _currentFeed;
  List<FeedItem> _allFeeds;
  int _currentIndex;
  bool _hidden = false;

  @override
  void dispose() {
    final AppStateWidgetState state = AppStateWidget.of(context);
    if (state.shouldShowAds) {
      createAndShowBannerAd();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppStateWidgetState state = AppStateWidget.of(context);
    // _images.removeRange(0, _images.length);
    _getFeeds(state);

    return Scaffold(
      // appBar: new AppBar(
      //   title: Text(_currentFeed.title),
      // ),
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          children: <Widget>[
            GestureDetector(
              child: PhotoViewGallery(
                pageOptions: _images,
                // loadingChild: widget.loadingChild,
                // backgroundDecoration: widget.backgroundDecoration,
                scaleStateChangedCallback: (PhotoViewScaleState scaleState) {
                  setState(() {
                    _hidden = (scaleState != PhotoViewScaleState.initial);
                  });
                },
                pageController: PageController(initialPage: widget.startIndex),
                onPageChanged: _onImageSwiped,
              ),
              onTap: () {
                setState(() {
                  _hidden = !_hidden;
                });
              },
            ),
            AnimatedPositioned(
              bottom: _hidden ? -300 : 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                // visible: !_hidden,
                opacity: _hidden ? 0.0 : 1,
                duration: Duration(milliseconds: 300),
                child: BottomAppBar(
                  color: Colors.black87,
                  child: getBottomButtonBar(
                    feed:_currentFeed, 
                    state: state, 
                    onDownload: widget.onDownload,
                    onShare: widget.onShare,
                    onFavorite: widget.onFavorite,
                  ),
                ),
              ),
              duration: Duration(milliseconds: 300),
            )
          ],
        )
      ),
      // bottomNavigationBar: Visibility(
      //   visible: !_hidden,
      //   child: BottomAppBar(
      //     color: Colors.black87,
      //     child: getBottomButtonBar(
      //       feed:_currentFeed, 
      //       state: state, 
      //       onDownload: widget.onDownload,
      //       onShare: widget.onShare,
      //       onFavorite: widget.onFavorite,
      //     ),
      //   ),
      // ),
    );
  }

  void _onImageSwiped(int index) {
    if (_currentIndex == index) {
      return;
    }
    setState(() {
      _currentIndex = index;
      _currentFeed =_allFeeds[index];
    });
    showInterstitialAdIfNecessary();
  }

  void _mapFeedsToGallery(List<FeedItem> feeds) {
    setState(() {
      if (_currentFeed == null) {
        _currentFeed = feeds[widget.startIndex];
      }
      _allFeeds = feeds;
      _images.addAll(
        feeds.map((feed) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(feed.link),
            heroTag: feed.title,
          );
        })
      );
    });
  }

  void _getFeeds(AppStateWidgetState state) {
    switch (state.activeTab) {
      case TabViewPages.Recent:
        _mapFeedsToGallery(state.recentFeeds);
        break;
      case TabViewPages.Popular:
        _mapFeedsToGallery(state.popularFeeds);
        break;
      case TabViewPages.Favorites:
        _mapFeedsToGallery(state.favoriteFeeds.reversed.toList());
        break;
      default:
        _mapFeedsToGallery(state.recentFeeds);
        break;
    }
  }
}
